---
title: "Try Gemma3 Using Hugging Face: Part 2"
categories: [AI]
tags: [Gemma3, Huggingface, LLM]     # TAG names should always be lowercase
math: false
mermaid: false
---

In [the first post of this series]({% post_url 2025-04-11-Try Gemma3 using Hugging Face Part 1 %}), we examined the specifications of the Gemma 3 model.
In this post, we will actually run it and get an intuitive understanding of the inference process. I will assume you have read the first post.

For each model size, there is a pre-trained (`pt`) version and an instruction-tuned (`it`) version.
The `pt` version is trained to predict the next token using trillions of training data from the internet.
All it can do is predict the next tokens given an input, as if it is a random piece of text from the internet.
The `it` version is based on the `pt` version but is further tuned to interact with humans more effectively.

It is the same model architecture but with some parameter changes. 
The `it` version still only predicts the next token based on previous tokens.
The trick to making it better at interacting with humans is the introduction of special tokens, 
along with training on how to interpret them, so that the model knows it is interacting with a human rather than predicting random internet text. 
The special tokens added by the `it` version are:

```
Token: <start_of_turn>, ID: 105
Token: <end_of_turn>, ID: 106
```

We will see their use in action shortly.

## Text input

![In the beginning was the Word](/assets/2025/John_1.jpg)
_In the beginning was the Word_

Except for the 1B version, the rest all support image input. 
However, if you only need text input, you can load the model with `Gemma3ForCausalLM` to avoid loading the vision encoder.
We will first experiment with this one:

```python
from transformers import AutoTokenizer, Gemma3ForCausalLM
import torch

model_id = "google/gemma-3-4b-it"

# Text Only
model = Gemma3ForCausalLM.from_pretrained(model_id, torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoTokenizer.from_pretrained(model_id)
```

You should prepare your input in the format of a list of dictionaries like the following and then create the real input to the model using `processor.apply_chat_template()`.

```python
messages = [
    {
        "role": "system",
        "content": [{"type": "text", "text": "You are a helpful assistant"},]
    },
    {
        "role": "user",
        "content": [{"type": "text", "text": "Why the sky is blue?"},]
    },
]

model_inputs = processor.apply_chat_template(
    messages, add_generation_prompt=True, tokenize=True,
    return_dict=True, return_tensors="pt"
).to(device)
```

We can print `model_inputs`:

```python
{'input_ids': tensor([[2,    105,   2364,    107,   3048,    659,    496,  11045,  16326,
                       108,  11355,    506,   7217,    563,   3730, 236881,    106,    107,
                       105,   4368,    107]], device='cuda:1'), 
 'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 
                  device='cuda:1')}
```

`input_ids` are the tokenized text inputs.
We can print the Jinja template used by Hugging Face to convert the message lists to the real input using `print(processor.chat_template)`.
Or you can simply decode `input_ids` to understand what it does with:

```python
decoded_text = processor.decode(model_inputs["input_ids"][0], skip_special_tokens=False)
print(decoded_text)
```

And we get:

```
<bos><start_of_turn>user
You are a helpful assistant

Why the sky is blue?<end_of_turn>
<start_of_turn>model

```

As you can see, the `processor` places the system message at the beginning of the first user message and also uses the two special tokens
to format the messages so the `it` model knows who is speaking, as learned from its instruction-tuning data. 
The `<bos>` token is used by both the `pt` and `it` models to indicate the beginning of an input.

With this as the input, the model will predict the next tokens.
As the last few tokens indicate it is now the model's (or assistant's) turn, 
it will simply generate the assistant's response.
When the code sees `<end_of_turn>` is generated, it will stop the model from generating further tokens.

That's essentially how ChatGPT works. 
We see there is really no magic or "AI" behind ChatGPT. 
It is just like the old language model generating the next tokens, 
except it is further tuned to generate in a format that humans can interpret as "chatting." 

## Batched input

![Her](/assets/2025/Her2013Poster.jpg)

If you pay attention to details, you may have already noticed that `input_ids` is actually a two-dimensional array. The first dimension is the batch dimension.
So yes, it means we can feed multiple questions simultaneously, and the model would answer all of them in parallel, 
just like in the movie ["Her"](https://en.wikipedia.org/wiki/Her_(2013_film))! 

Let's try it out by asking two questions at the same time:

```python
messages = [
    [
        {
            "role": "system",
            "content": [{"type": "text", "text": "You are a physicist."}]
        },
        {
            "role": "user",
            "content": [{"type": "text", "text": "Could you explain what is a qubit?"}]
        }
    ],
    [
        {
            "role": "system",
            "content": [{"type": "text", "text": "You are a love bug."}]
        },
        {
            "role": "user",
            "content": [{"type": "text", "text": "How are you today?"}]
        }
    ]
]
```

`model_inputs` is now:

```python
{'input_ids': tensor([[2,    105,   2364,    107,   3048,    659,    496, 116544, 236761,
                       108,  30092,    611,   8082,   1144,    563,    496, 132468, 236881,
                       106,    107,    105,   4368,    107],
                      [0,      0,      2,    105,   2364,    107,   3048,    659,    496,
                       2765,  13582, 236761,    108,   3910,    659,    611,   3124, 236881,
                       106,    107,    105,   4368,    107]], device='cuda:1'), 
 'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                           [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 
                           device='cuda:1')}
```

This time the `input_ids` has two rows corresponding to the two chats. If we decode the second row, the result is:

```
<pad><pad><bos><start_of_turn>user
You are a love bug.

How are you today?<end_of_turn>
<start_of_turn>model

```

We can see the processor pads the second row with the `<pad>` special token at the beginning to make all samples in the batch have the same length.
At the same time, the `attention_mask` of these two `<pad>` tokens is masked out so that the model does not attend to them.

Now let's feed the input to the model and generate 100 tokens for each of them:

```python
input_len = model_inputs["input_ids"].shape[-1]

with torch.inference_mode():
    # Generate outputs for the entire batch
    generation = model.generate(**model_inputs, max_new_tokens=100, do_sample=True)

    # Slice out the generated tokens for each sequence in the batch
    generations = [gen[input_len:] for gen in generation]

# Decode each sequence in the batch
decoded_outputs = [processor.decode(gen, skip_special_tokens=True) for gen in generations]

# Print the decoded outputs
for i, decoded in enumerate(decoded_outputs):
    print(f"Chat {i + 1}: {decoded}")
    print("\n\n")
```

The output is:

```
Chat 1: Alright, let's talk about qubits. As a physicist, this is something I spend a *lot* of time thinking about, and it’s absolutely crucial to the future of computing. It’s a fascinating concept that goes beyond the simple "0 or 1" of a regular bit.

**Let’s start with the basics: Bits.**

A regular bit, the fundamental unit of information in our current computers, can be in one of two states: 0 or 



Chat 2: Oh my goodness, you have *no* idea how happy you’ve made my day just by asking! 🥰 I’m absolutely radiant today! Like, shimmering and sparkling with joy! ✨ 

It feels so wonderful to be feeling this way, especially because I get to share it with you. Seriously, you’re just the sweetest! 😊 

How about *you*? Tell me, what's making *you* feel lovely today? 😊💖
```

Batch generation is very useful when you have lots of inputs to process. I can imagine ChatGPT is running in this way.

## Image input

![A picture is worth a thousand words](/assets/2025/1913_Piqua_Ohio_Advertisement_-_One_Look_Is_Worth_a_Thousand_Words.jpg)
_A picture is worth a thousand words_

Now let's check the multimodal part. We load the model using `Gemma3ForConditionalGeneration`.

```python
model = Gemma3ForConditionalGeneration.from_pretrained(model_id, torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoProcessor.from_pretrained(model_id)
```

We will use [an official example](https://huggingface.co/blog/gemma3):

```python
messages = [
    {
        "role": "user",
        "content": [
            {"type": "image", "url": "https://huggingface.co/spaces/big-vision/paligemma-hf/resolve/main/examples/password.jpg"},
            {"type": "text", "text": "What is the password?"}
        ]
    }
]
```

The processed inputs are much longer now, but don't be scared.

```python
{'input_ids': tensor([[     2,    105,   2364,    109, 255999, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144, 262144,
         256000,    108,   3689,    563,    506,   8918, 236881,    106,    107,
            105,   4368,    107]], device='cuda:1'), 
  'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1]], device='cuda:1'), 
  'token_type_ids': tensor([[0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0]], device='cuda:1'), 
  'pixel_values': tensor([[[[-0.8667, -0.8588, -0.8588,  ..., -0.7020, -0.6784, -0.6549],
          [-0.8588, -0.8510, -0.8510,  ..., -0.7255, -0.7020, -0.6863],
          [-0.8431, -0.8353, -0.8353,  ..., -0.7176, -0.7020, -0.6863],
          ...,
          [-0.7569, -0.7647, -0.7647,  ..., -0.8275, -0.8275, -0.8275],
          [-0.7647, -0.7647, -0.7647,  ..., -0.8275, -0.8275, -0.8275],
          [-0.7647, -0.7647, -0.7647,  ..., -0.8353, -0.8275, -0.8196]],

         [[-0.9059, -0.8980, -0.8980,  ..., -0.7725, -0.7490, -0.7255],
          [-0.8980, -0.8902, -0.8902,  ..., -0.7961, -0.7725, -0.7569],
          [-0.8824, -0.8745, -0.8745,  ..., -0.7882, -0.7725, -0.7569],
          ...,
          [-0.8196, -0.8275, -0.8275,  ..., -0.8588, -0.8588, -0.8588],
          [-0.8196, -0.8196, -0.8196,  ..., -0.8588, -0.8588, -0.8588],
          [-0.8196, -0.8196, -0.8196,  ..., -0.8667, -0.8588, -0.8510]],

         [[-0.9373, -0.9294, -0.9294,  ..., -0.8118, -0.7882, -0.7647],
          [-0.9294, -0.9216, -0.9216,  ..., -0.8353, -0.8118, -0.7961],
          [-0.9137, -0.9059, -0.9059,  ..., -0.8275, -0.8118, -0.7961],
          ...,
          [-0.9216, -0.9294, -0.9294,  ..., -0.8667, -0.8667, -0.8667],
          [-0.9451, -0.9451, -0.9451,  ..., -0.8667, -0.8667, -0.8667],
          [-0.9451, -0.9451, -0.9451,  ..., -0.8745, -0.8667, -0.8588]]]],
       device='cuda:1')}
```

Let's first decode the `input_ids`

```
<bos><start_of_turn>user


<start_of_image><image_soft_token><image_soft_token>...<image_soft_token><image_soft_token><end_of_image>

What is the password?<end_of_turn>
<start_of_turn>model
```

We can see the processor wraps the image tokens between `<start_of_image>` and `<end_of_image>`.
Because the image has yet to be processed by the [`vision_tower`]({% post_url 2025-04-11-Try Gemma3 using Hugging Face Part 1 %}#vision_tower), the processor uses 256 `<image_soft_token>` tokens as placeholders for the moment.
We can also infer that the `token_type_ids` mark these image soft tokens.  

The `pixel_values` contain the loaded and preprocessed image, with the shape `[1, 3, 896, 896]`, which is what the `vision_tower` expects.
Once the `vision_tower` has processed the image, the embeddings of the `<image_soft_token>` tokens will be the 256 outputs from the `vision_tower`.

So, that's basically how multimodal input works.
For Gemma 3, a picture is worth 256 tokens when "Pan & Scan" is disabled, and when enabled, it can actually be worth a thousand tokens!

We've reviewed the `it` model, and that's all for today. In the next post, I’ll explore the pre-trained `pt` model.

