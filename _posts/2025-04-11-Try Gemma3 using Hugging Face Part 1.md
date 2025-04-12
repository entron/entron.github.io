---
title: "Try Gemma3 Using Hugging Face: Part 1"
categories: [AI]
tags: [Gemma3, Huggingface, LLM]     # TAG names should always be lowercase
math: false
mermaid: false
---

Recently, I've become quite fascinated by small LLMs such as Gemma 3 and the idea of running them locally.  
I tried out [Ollama](https://ollama.com/), which builds on top of [llama.cpp](https://github.com/ggml-org/llama.cpp) but wraps it in an elegant, user-friendly way.  
It feels like Docker for LLMs—and I really love it.

I also read [the technical report of Gemma 3](https://arxiv.org/abs/2503.19786) and some of the papers it cites, learning a ton in the process.  
A lot of progress has been made since the days of GPT-2 ([nanoGPT]({% post_url 2025-04-01-NanoGPT code map visualizing GPT architecture %})).

Today, I experimented with running Gemma 3 via [Hugging Face](https://huggingface.co/docs/transformers/en/index) to get a deeper understanding of how it works.  
Here’s a summary of what I did and discovered.

## Versions

Gemma 3 has four size variants: 1B, 4B, 12B, and 27B. Each has two versions on HuggingFace (HF): `pt` stands for pre-trained and `it` stands for instruction-tuned. These 8 models use `bfloat16` precision for their weights as in the training. There are also quantized versions for each of these 8 models with the suffix `qat-q4_0-gguf` in the model name. These are produced using Quantization Aware Training (QAT) described in the paper, so I expect them to have better quality than using `bfloat16` version models and then loading them with `BitsAndBytesConfig(load_in_4bit=True)` in HF. 

By the way, I suspect the quantized version on Ollama currently is also not the version using QAT, as the QAT version seems to have only been released on HuggingFace about a week ago. One can use 

```bash
ollama run hf.co/google/gemma-3-27b-it-qat-q4_0-gguf
```

for example, to run the QAT version from HF using Ollama.

You can find all these models [here](https://huggingface.co/collections/google/gemma-3-release-67c6c6f89c4f76621268bb6d).

## Tokens

I used the following code to print the first 10K and last 10K tokens of the tokenizer used by the Gemma 3 models (shared by both `pt` and `it` variants).

```python
model_id = "google/gemma-3-4b-it"
processor = AutoTokenizer.from_pretrained(model_id)

# Define parameters for the number of tokens to inspect
N_first = 10000  # Number of tokens to inspect from the beginning
N_last = 10000   # Number of tokens to inspect from the end

# Get the tokenizer vocabulary
vocab = processor.get_vocab()

# Sort the vocabulary by token IDs
sorted_vocab = sorted(vocab.items(), key=lambda item: item[1])

# Extract the first N and last N tokens
first_N_tokens = sorted_vocab[:N_first]
last_N_tokens = sorted_vocab[-N_last:]

print(f"First {N_first} tokens in the tokenizer:")
for token, token_id in first_N_tokens:
    print(f"Token: {token}, ID: {token_id}")

print(f"\nLast {N_last} tokens in the tokenizer:")
for token, token_id in last_N_tokens:
    print(f"Token: {token}, ID: {token_id}")
```

The result is [here](https://gist.github.com/entron/ff5c1260ed6cf892493d2ae5b4889270).
From this list, we can identify the special tokens used:

```
Token: <pad>, ID: 0
Token: <eos>, ID: 1
Token: <bos>, ID: 2
Token: <unk>, ID: 3
Token: <mask>, ID: 4
Token: [multimodal], ID: 5
Token: <start_of_turn>, ID: 105
Token: <end_of_turn>, ID: 106
Token: <start_of_image>, ID: 255999
Token: <end_of_image>, ID: 256000
Token: <image_soft_token>, ID: 262144
```

There are 99 unused tokens at the beginning and more than 6000 at the end of the token list.
I assume these are reserved for fine-tuning the model for specific tasks.

Interestingly, we also see that the tokenizer includes complete HTML-like syntax tokens near the beginning, 
without splitting them into sub-parts like [BPE](https://en.wikipedia.org/wiki/Byte_pair_encoding), which is used by OpenAI.

```
Token: <table>, ID: 168
Token: <caption>, ID: 169
Token: <thead>, ID: 170
Token: <tbody>, ID: 171
Token: <tfoot>, ID: 172
Token: <tr>, ID: 173
Token: <th>, ID: 174
Token: <td>, ID: 175
Token: </table>, ID: 176
Token: </caption>, ID: 177
Token: </thead>, ID: 178
Token: </tbody>, ID: 179
Token: </tfoot>, ID: 180
Token: </tr>, ID: 181
Token: </th>, ID: 182
Token: </td>, ID: 183
Token: <h1>, ID: 184
Token: <h2>, ID: 185
```
These HTML tags are also grouped together, making the vocabulary far more readable compared to [the result from OpenAI's tokenizer](https://gist.github.com/entron/230d3a679f0a0fcc7cdbb274e0c7f9fa) 
While this might not matter for typical end users, making the model perceive tokens closer to how we perceive text could have various benefits.

## Model 

### Overview

First, let's print the model config. I’ll use the 4B instruction-tuned model as an example in the following.

```python
config = AutoConfig.from_pretrained("google/gemma-3-4b-it")
print(config)
```

The result is

```
Gemma3Config {
  "architectures": [
    "Gemma3ForConditionalGeneration"
  ],
  "boi_token_index": 255999,
  "eoi_token_index": 256000,
  "eos_token_id": [
    1,
    106
  ],
  "image_token_index": 262144,
  "initializer_range": 0.02,
  "mm_tokens_per_image": 256,
  "model_type": "gemma3",
  "text_config": {
    "attention_bias": false,
    "attention_dropout": 0.0,
    "attn_logit_softcapping": null,
    "cache_implementation": "hybrid",
    "final_logit_softcapping": null,
    "head_dim": 256,
    "hidden_activation": "gelu_pytorch_tanh",
    "hidden_size": 2560,
    "initializer_range": 0.02,
    "intermediate_size": 10240,
    "max_position_embeddings": 131072,
    "model_type": "gemma3_text",
    "num_attention_heads": 8,
    "num_hidden_layers": 34,
    "num_key_value_heads": 4,
    "query_pre_attn_scalar": 256,
    "rms_norm_eps": 1e-06,
    "rope_local_base_freq": 10000.0,
    "rope_scaling": {
      "factor": 8.0,
      "rope_type": "linear"
    },
    "rope_theta": 1000000.0,
    "sliding_window": 1024,
    "sliding_window_pattern": 6,
    "use_cache": true,
    "vocab_size": 262208
  },
  "torch_dtype": "bfloat16",
  "transformers_version": "4.50.3",
  "vision_config": {
    "attention_dropout": 0.0,
    "hidden_act": "gelu_pytorch_tanh",
    "hidden_size": 1152,
    "image_size": 896,
    "intermediate_size": 4304,
    "layer_norm_eps": 1e-06,
    "model_type": "siglip_vision_model",
    "num_attention_heads": 16,
    "num_channels": 3,
    "num_hidden_layers": 27,
    "patch_size": 14,
    "vision_use_head": false
  }
}
```

There are two ways to load the 4B model. One is for text-only input:

```python
# Text Only
model = Gemma3ForCausalLM.from_pretrained(model_id, torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoTokenizer.from_pretrained(model_id)
```

And the other is for both image and text inputs:

```python
# Image and text as input
model = Gemma3ForConditionalGeneration.from_pretrained(model_id, torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoProcessor.from_pretrained(model_id)
```

Let’s `print(model)` for the multimodal case to inspect the full model architecture.
As you'll see, it contains the text-only model `Gemma3ForCausalLM` as a component:

```
Gemma3ForConditionalGeneration(
  (vision_tower): SiglipVisionModel(
    (vision_model): SiglipVisionTransformer(
      (embeddings): SiglipVisionEmbeddings(
        (patch_embedding): Conv2d(3, 1152, kernel_size=(14, 14), stride=(14, 14), padding=valid)
        (position_embedding): Embedding(4096, 1152)
      )
      (encoder): SiglipEncoder(
        (layers): ModuleList(
          (0-26): 27 x SiglipEncoderLayer(
            (self_attn): SiglipSdpaAttention(
              (k_proj): Linear(in_features=1152, out_features=1152, bias=True)
              (v_proj): Linear(in_features=1152, out_features=1152, bias=True)
              (q_proj): Linear(in_features=1152, out_features=1152, bias=True)
              (out_proj): Linear(in_features=1152, out_features=1152, bias=True)
            )
            (layer_norm1): LayerNorm((1152,), eps=1e-06, elementwise_affine=True)
            (mlp): SiglipMLP(
              (activation_fn): PytorchGELUTanh()
              (fc1): Linear(in_features=1152, out_features=4304, bias=True)
              (fc2): Linear(in_features=4304, out_features=1152, bias=True)
            )
            (layer_norm2): LayerNorm((1152,), eps=1e-06, elementwise_affine=True)
          )
        )
      )
      (post_layernorm): LayerNorm((1152,), eps=1e-06, elementwise_affine=True)
    )
  )
  (multi_modal_projector): Gemma3MultiModalProjector(
    (mm_soft_emb_norm): Gemma3RMSNorm((1152,), eps=1e-06)
    (avg_pool): AvgPool2d(kernel_size=4, stride=4, padding=0)
  )
  (language_model): Gemma3ForCausalLM(
    (model): Gemma3TextModel(
      (embed_tokens): Gemma3TextScaledWordEmbedding(262208, 2560, padding_idx=0)
      (layers): ModuleList(
        (0-33): 34 x Gemma3DecoderLayer(
          (self_attn): Gemma3Attention(
            (q_proj): Linear(in_features=2560, out_features=2048, bias=False)
            (k_proj): Linear(in_features=2560, out_features=1024, bias=False)
            (v_proj): Linear(in_features=2560, out_features=1024, bias=False)
            (o_proj): Linear(in_features=2048, out_features=2560, bias=False)
            (q_norm): Gemma3RMSNorm((256,), eps=1e-06)
            (k_norm): Gemma3RMSNorm((256,), eps=1e-06)
          )
          (mlp): Gemma3MLP(
            (gate_proj): Linear(in_features=2560, out_features=10240, bias=False)
            (up_proj): Linear(in_features=2560, out_features=10240, bias=False)
            (down_proj): Linear(in_features=10240, out_features=2560, bias=False)
            (act_fn): PytorchGELUTanh()
          )
          (input_layernorm): Gemma3RMSNorm((2560,), eps=1e-06)
          (post_attention_layernorm): Gemma3RMSNorm((2560,), eps=1e-06)
          (pre_feedforward_layernorm): Gemma3RMSNorm((2560,), eps=1e-06)
          (post_feedforward_layernorm): Gemma3RMSNorm((2560,), eps=1e-06)
        )
      )
      (norm): Gemma3RMSNorm((2560,), eps=1e-06)
      (rotary_emb): Gemma3RotaryEmbedding()
      (rotary_emb_local): Gemma3RotaryEmbedding()
    )
    (lm_head): Linear(in_features=2560, out_features=262208, bias=False)
  )
)
```

### vision_tower

So, images pass through the entire `vision_tower` before entering the first layer of the language model.

This reminds me of a widely circulated article in China "I struggled for 18 years just to sit and have coffee with you!".  
It was originally a blog post by a student from a humble background who, after years of hardship, made it into Peking University. 
In the story, the student reflects on how much effort it took just to sit in the same café as someone born into privilege.
I imagine the image patches must feel the same after going through all 27 `SiglipEncoderLayer`s!
But there's some consolation: all Gemma 3 models use the same `vision_tower`, 
so even for the 27B model, they still only need to go through 27 layers—and not more.

The `vision_tower` uses a `Conv2d(3, 1152, kernel_size=(14, 14), stride=(14, 14), padding=valid)` to convert images into image patch embeddings.
Since the stride equals the kernel size, it scans the image with non-overlapping patches.
Each patch maps to a 1152-dimensional vector.
In parallel, the `position_embedding: Embedding(4096, 1152)` maps 64×64 = 4096 positions to vectors of the same size.
Therefore, the `vision_tower` expects images of size 896×896 (since 896 = 14×64).

What about images of a different size?

This is handled by the tokenizer rather than the model.
According to the technical paper, Gemma 3 uses the **Pan & Scan (P&S)** technique during inference.
If you want to understand the details, check out [the code](https://github.com/huggingface/transformers/blob/953196a43dae6a3c474165fba7d215fcbc7b7730/src/transformers/models/gemma3/image_processing_gemma3.py).
However, P&S does not seem to be enabled by default.
The code will simply rescale the input image to 896×896.
If you want to enable P&S, you can use something like:

```python
inputs = processor.apply_chat_template(
    messages,
    add_generation_prompt=True,
    tokenize=True,
    return_dict=True,
    return_tensors="pt",
    images_kwargs={
        "do_pan_and_scan": True,
        "pan_and_scan_max_num_crops": 4,
        "pan_and_scan_min_crop_size": 256,
        "pan_and_scan_min_ratio_to_activate": 1.2,
    }
).to(model.device)
```

### multi_modal_projector

Let’s continue examining the model.
For each image input of size 896×896, the embedding layer converts it into 4096 patches.
These are processed by the 27 `SiglipEncoderLayer`s, resulting in 4096 tokens per image, each a 1152-dimensional vector.

The `multi_modal_projector` module connects the output of the `vision_tower` to the input of the LLM (`language_model`).
It does two key things:

1. Projects 1152-dimensional vectors to 2560, which is the hidden size used by the LLM.  
2. Applies a non-overlapping 4×4 average pooling to reduce token count from 4096 to 256 per image.

But wait—aren’t the outputs from `vision_tower` 1D token sequences? Why use `AvgPool2d`?
And where is the projection layer from 1152 to 2560?

To answer this, we have to look at the [implementation](https://github.com/huggingface/transformers/blob/953196a43dae6a3c474165fba7d215fcbc7b7730/src/transformers/models/gemma3/modular_gemma3.py) of `Gemma3MultiModalProjector`:

```python
class Gemma3MultiModalProjector(nn.Module):
    def __init__(self, config: Gemma3Config):
        super().__init__()

        self.mm_input_projection_weight = nn.Parameter(
            torch.zeros(config.vision_config.hidden_size, config.text_config.hidden_size)
        )

        self.mm_soft_emb_norm = Gemma3RMSNorm(
            config.vision_config.hidden_size, eps=config.vision_config.layer_norm_eps
        )

        self.patches_per_image = int(config.vision_config.image_size // config.vision_config.patch_size)
        self.tokens_per_side = int(config.mm_tokens_per_image**0.5)
        self.kernel_size = self.patches_per_image // self.tokens_per_side
        self.avg_pool = nn.AvgPool2d(kernel_size=self.kernel_size, stride=self.kernel_size)

    def forward(self, vision_outputs: torch.Tensor):
        batch_size, _, seq_length = vision_outputs.shape

        reshaped_vision_outputs = vision_outputs.transpose(1, 2)
        reshaped_vision_outputs = reshaped_vision_outputs.reshape(
            batch_size, seq_length, self.patches_per_image, self.patches_per_image
        )
        reshaped_vision_outputs = reshaped_vision_outputs.contiguous()

        pooled_vision_outputs = self.avg_pool(reshaped_vision_outputs)
        pooled_vision_outputs = pooled_vision_outputs.flatten(2)
        pooled_vision_outputs = pooled_vision_outputs.transpose(1, 2)

        normed_vision_outputs = self.mm_soft_emb_norm(pooled_vision_outputs)

        projected_vision_outputs = torch.matmul(normed_vision_outputs, self.mm_input_projection_weight)
        return projected_vision_outputs.type_as(vision_outputs)
```

The projection is done using `mm_input_projection_weight`, which is an `nn.Parameter` rather than an `nn.Module`.
That’s why it doesn't show up in the model summary when you print it.

To apply average pooling, the model first reshapes the 1D token sequence back into a 2D grid, recovering spatial relationships.  

```python
reshaped_vision_outputs = vision_outputs.transpose(1, 2)
reshaped_vision_outputs = reshaped_vision_outputs.reshape(
    batch_size, seq_length, self.patches_per_image, self.patches_per_image
)
```
After pooling, it flattens the 2D grid back into a 1D token sequence for further processing.

```python
pooled_vision_outputs = pooled_vision_outputs.flatten(2).transpose(1, 2)
```

### language_model

After both the image patches and you have endured, we finally enter the LLM part.

`Gemma3TextScaledWordEmbedding(262208, 2560, padding_idx=0)`
tells us that the vocabulary size is 256k and the hidden dimension is 2560 (for the 4B model).

The 4B model contains 34 transformer blocks (`Gemma3DecoderLayer`).
Inside each, the Q projection has twice the size of K and V, because Gemma 3 uses Grouped-Query Attention (GQA).
Also, the MLP uses an additional `gate_proj`, because Gemma 3 adopts [Gated Linear Units (GLU)](https://arxiv.org/pdf/2002.05202)—
which "[seems to work due to divine benevolence](https://www.reddit.com/r/MachineLearning/comments/1b6ggpz/d_why_do_glus_gated_linear_units_work/)".

Like basically every modern LLM, it uses [rotary positional embeddings (RoPE)](https://arxiv.org/abs/2104.09864).
RoPE is an extremely interesting topic, and I want to discuss it in a separate post.
Gemma 3 has two RoPEs: `rotary_emb` and `rotary_emb_local`.

Why two? According to the technical report:  
> Gemma 3 alternates between a local sliding window self-attention and global self-attention, with a pattern of 5 local layers for every global layer—starting with a local layer.

Then how does this play out with 34 layers? Let’s peek into [the code](https://github.com/huggingface/transformers/blob/953196a43dae6a3c474165fba7d215fcbc7b7730/src/transformers/models/gemma3/modeling_gemma3.py):

```python
self.is_sliding = bool((layer_idx + 1) % config.sliding_window_pattern)
```
where `config.sliding_window_pattern = 6`. 
This means only layer 5, 11, 17, 23, 29 are global layers.
The rest—including the top layers—are local.
Interesting! I assumed the top layer would be global, but apparently not.

## Conclusion

Gemma 3 is a small model packed with a lot of innovation, and backed by massive effort and $$$ from Google.
It’s definitely worth a deep dive if you’re interested in LLMs.

I feel I now have a solid overview of the Gemma 3 model—and I hope you do too!
In Part 2, I’ll actually run the model and do some experiments. Stay tuned!
