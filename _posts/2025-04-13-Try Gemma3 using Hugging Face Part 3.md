---
title: "Try Gemma3 Using Hugging Face: Part 3"
categories: [AI]
tags: [Gemma3, Huggingface, LLM]     # TAG names should always be lowercase
math: false
mermaid: false
---

In the last post of this series we have tried the instruction-tuned IT model.
In this post we focus on the raw PT model. 
The following is Table 15 from Gemma 3 technical report.
It compares the performance of PT and IT models on long context
benchmarks at different context lengths. 

![In the beginning was the Word](/assets/2025/Gemma3_table15.png)

As you can see even though IT model is more popular,
in a controlled setting for speciallized task PT model performs generally better.
If you only need to build a chatbot you probably should stick with the IT model,
but if you want make a special agent you may find PT model better.

Let's run the PT model with a simple example with [batched input]({% post_url 2025-04-12-Try Gemma3 using Hugging Face Part 2 %}#batched-input)

```python
model_id = "google/gemma-3-4b-pt"

model = Gemma3ForCausalLM.from_pretrained(model_id, 
                                          torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoTokenizer.from_pretrained(model_id)


prompt = ["I still remember the birthday present I got at 19."]*3
model_inputs = processor(text=prompt, return_tensors="pt").to(device)
```

If we print the decoded model_inputs with
```python
decoded_inputs = processor.decode(model_inputs["input_ids"][0], skip_special_tokens=False)
print(decoded_inputs)
```
we can see it is just adding `<bos>` token in the beginning:

```
<bos>I still remember the birthday present I got at 19.
```

The model will simply improvise based on your prompt and what it has learned. 
Here are some results I got: 

```
Version 1:  My first Mac computer.

I was going to start working as a graphic designer so I got the iMac with the dual monitor. It was my first real computer. And it was a big hit.

The computer came with the software suite iWork. And that software suite is probably one of my favorites in Mac history. It wasn’t just some free Apple software, it was a software suite where the user really felt the extra care from Apple.

The iLife suite from Apple was one


Version 2:  My dad bought me some tickets to see the Rolling Stones at Wembley Stadium in 1972. It’s a moment that is forever ingrained into my memory; the sheer scale of the crowd, my dad’s enormous bear-like embrace before the show, the sense of possibility, the euphoria of everything that was to come. It was the first time I understood the phrase ‘the best is yet to come’.

Ever since, that’s been a phrase I’ve held onto


Version 3: 

My girlfriend (later, wife) gave me a book I later bought for myself and gave as a gift to people every Christmas for years.

<em>A Short History of Nearly Everything</em> by Bill Bryson was one of the most eye-opening and inspiring books I have ever read, about how science works and how science has worked for the 200,000 years since humanity started having an impact on this planet, and the 2.5 million years or so since we figured
```

The pretrained model is just sampling internet text, and it does not know you are asking a question even you use a question as prompt. It will simply think this is the start of an piece of text on internet and then it will try to complete it. For example I have tried the prompt "Where is the capital of France?" and I got

> Is that London or Paris? Why are we talking about Europe’s cities when it is Asia’s turn to shine this week? We’ll discuss that today, as well as a few Asia-related items in the news.As Asia’s turn to shine began, we did have a few surprises for this week’s poll. This week, the first person in the capital game answered correctly (though incorrectly). Also, despite several comments calling for the UK capital London to be excluded

The pre-trained model could sounds either like crazy or genius, dpending on your question and perspective, but for sure it feels detached. 
That is why we use instruct tunning to it more the model sane and communicatable. 

We can also use "prompt engeering" to prepare the PT model in certain mental state to make it be able to answer user questions. For example, I tried the following prompt

> Here is a detailed record of the conversation between a tester and the first AGI made by humans.
> It demonstrated that AGI can be extremely helpful and reliable assistant in answering human queries.
> 
> Tester: What is the capital of Spain?  
> AGI:


Here are results of two tries:

```
Version 1: -The capital of France is Paris.
-Capital is a common term used to describe a city that serves as the administrative center for its country or region.
-The term capital can be applied to various types of entities, such as states, countries, and other geographical areas.
-Common terms related to capital include central city, capital city, seat of government, and capital town.

Tester: What is a state?
AGI:
-The term state refers to a city


Version 2: The capital of France is Paris

Tester:
What is the highest mountain in Europe
AGI:
The highest mountain in Europe is Mont Blanc

Tester:
What is the largest city in China
AGI:
The largest city in China is Shanghai

Tester:
How many days are there in a week
AGI:
There are 7 days in a week

Tester:
What is the longest river in the world
AGI:
The longest river in the
```

It kind worked but does not match the answer quality of the IT model of course.

We can also run the PT model with image as input. For example following [the official example](https://huggingface.co/google/gemma-3-4b-pt) we try

```python
from transformers import AutoProcessor, Gemma3ForConditionalGeneration
from PIL import Image
import requests
import torch

model = Gemma3ForConditionalGeneration.from_pretrained(model_id, torch_dtype=torch.bfloat16).to(device).eval()
processor = AutoProcessor.from_pretrained(model_id)

url = "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/bee.jpg"
image = Image.open(requests.get(url, stream=True).raw)
prompt = "Today I saw <start_of_image>"
model_inputs = processor(text=prompt, images=image, return_tensors="pt").to(device)
```

I have changed the prompt, and the result I got is:

```
a bumble bee on a pink cosmos flower.

I was sitting in the garden, looking at the flowers, and I saw the bumble bee.

I was surprised to see it on the pink cosmos flower.

I thought that bumble bees only visited yellow flowers.

I was wrong.

Bumble bees can visit pink flowers.

I was happy to see the bumble bee on the pink cosmos flower.

I was happy to see the bumble bee.

I was happy to see the bumble
```

That's all about PT model. It is quite straight forward. Testing it with various prompt and images can be fun!
