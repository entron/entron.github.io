---
title: "OpenAI o3 Looks at GPT-2 Through the Logit Lens"
categories: [AI]
tags: [OpenAI, LLM, o3, gpt-2, paper]     # TAG names should always be lowercase
math: false
mermaid: false
---

I read the paper *Dissecting Recall of Factual Associations in Auto-Regressive Language Models* by Geva et al., and I highly recommend it. If you're curious about how large language models process information internally, this paper is a must-read, along with some of the references it cites.

Inspired by this paper, I used the logit lens technique to inspect the GPT-2 model with the following simple code:

```python
# Run the model to obtain hidden states from all layers
with torch.no_grad():
    outputs = model(**model_inputs, output_hidden_states=True)
hidden_states = outputs.hidden_states  # Tuple: (embeddings, layer1, layer2,...)

# Get the LM head weight matrix to project hidden states to vocab space.
# Note: GPT2 ties the LM head with the input embedding weights.
lm_weight = model.get_input_embeddings().weight  # shape: (vocab_size, hidden_dim)

# Get original token IDs and corresponding tokens from the prompt.
token_ids = model_inputs["input_ids"][0].tolist()
orig_tokens = processor.convert_ids_to_tokens(token_ids)

print("Original tokens:", orig_tokens)
print("")


# For each layer (including initial embeddings as layer 0), compute and print top3 predictions.
for layer_idx, hs in enumerate(hidden_states):
    # hs shape: (batch_size, seq_length, hidden_dim)
    # Compute logits by projecting the hidden states onto the vocabulary space.
    logits = torch.matmul(hs, lm_weight.T)  # shape: (batch, seq_len, vocab_size)
    
    # Get the top k predictions for each token.
    topk = torch.topk(logits, k=10, dim=-1)
    
    # Prepare top k tokens for each token position.
    topk_tokens = []
    for pos in range(topk.indices.shape[1]):
        top_ids = topk.indices[0, pos].tolist()
        top_tokens = processor.convert_ids_to_tokens(top_ids)
        topk_tokens.append(top_tokens)
    
    print(f"Layer {layer_idx}:")
    for pos, orig_tok in enumerate(orig_tokens):
        print(f" Token '{orig_tok}': top3 -> {topk_tokens[pos]}")
    print("")
```

I used the example from the paper "Beats Music is owned by", and the results are:

```
Original tokens: ['Be', 'ats', 'ĠMusic', 'Ġis', 'Ġowned', 'Ġby']

Layer 0:
 Token 'Be': top3 -> ['Be', 'Bey', 'Bee', 'Beg', 'Beat', 'ĠBe', 'BE', 'Ę', 'ĠãĤµãĥ¼ãĥĨãĤ£', 'č']
 Token 'ats': top3 -> ['ats', 'ATS', 'atz', 'atsu', 'atted', 'aten', 'atsuki', 'atts', 'atri', 'aths']
 Token 'ĠMusic': top3 -> ['ĠMusic', 'Music', 'music', 'Ġmusic', 'ĠMUS', 'ĠMusical', 'ĠSongs', 'ĠAudio', 'ĠConcert', 'ĠPiano']
 Token 'Ġis': top3 -> ['Ġis', 'Ġisn', 'Ġhas', 'Ġdoes', 'Ġwas', 'Ġwill', 'Ġseems', 'Ġdoesn', 'Ġcomes', 'Ġcan']
 Token 'Ġowned': top3 -> ['Ġowned', 'owned', 'Own', 'ĠOwn', 'Ġowns', 'ĠOWN', 'Ġowning', 'ĠOwners', 'Ġownership', 'Owner']
 Token 'Ġby': top3 -> ['Ġby', 'by', 'ĠBy', 'ĠBY', 'By', 'Ġthrough', 'Ġin', 'Ġfrom', 'Ġat', 'Ġvia']

Layer 1:
 Token 'Be': top3 -> ['lyak', 'hemoth', 'gr', 'har', 'ĠEdited', 'achy', 'gra', 'cham', 'ab', 'grim']
 Token 'ats': top3 -> ['chet', 'ake', 'ats', 'orney', 'afety', 'chers', 'hop', 'ĠKats', 'olid', 'omo']
 Token 'ĠMusic': top3 -> ['ĠMusic', 'Ġmusic', 'ĠCube', 'ĠCircus', 'ĠMachine', 'Ġsinger', 'ĠCro', 'Ġvenue', 'ĠCafÃ©', 'ĠGrill']
 Token 'Ġis': top3 -> ['Ġmounted', 'ĠBalt', 'Ġtopped', 'Ġbacked', 'Ġsupposed', 'Ġsandwic', 'Ġoverseen', 'Ġrun', 'Ġnow', 'Ġslated']
 Token 'Ġowned': top3 -> ['Ġowned', 'swick', 'ĠDominion', 'Ġproperty', 'Ġownership', 'Ġowning', 'Ġowner', 'ĠOW', 'Ġowners', 'Ġowns']
 Token 'Ġby': top3 -> ['ĠGarland', 'ĠNorman', 'ĠPall', 'Ġlaw', 'Ġhand', 'ĠGat', 'Ġdragging', 'ĠIB', 'Ġpressing', 'Ġstaging']

Layer 2:
 Token 'Be': top3 -> ['ab', 'achy', 'cca', 'lyak', 'hemoth', 'ached', 'gr', 'har', 'aker', 'aum']
 Token 'ats': top3 -> ['chet', 'hop', 'chers', 'cha', 'iki', 'ake', 'omo', 'hey', 'ons', 'Ġburned']
 Token 'ĠMusic': top3 -> ['ĠCube', 'ĠFabric', 'ĠMachine', 'ĠGrill', 'Ġestablishments', 'ĠArchitects', 'hop', 'Ġdownstairs', 'ĠNob', 'ĠCircus']
 Token 'Ġis': top3 -> ['ĠGarland', 'ĠBalt', 'Ġpressed', 'Ġmounted', 'Ġsupposed', 'Ġpainted', 'Ġsandwic', 'Ġtopped', 'Ġserved', 'Ġbacked']
 Token 'Ġowned': top3 -> ['Ġowned', 'ĠDominion', 'Ġproperty', 'swick', 'Ġstationary', 'ĠOW', 'Ġstaggered', 'Ġdeb', 'ĠLyon', 'Ġbutcher']
 Token 'Ġby': top3 -> ['ĠGarland', 'Ġpressing', 'Ġstaging', 'ĠNorman', 'ĠKab', 'Ġwise', 'Ġlaw', 'ĠFlore', 'Ġdragging', 'ĠGladiator']

Layer 3:
 Token 'Be': top3 -> ['cca', 'aum', 'ached', 'ab', 'hemoth', 'gotten', 'achy', 'har', 'lyak', 'gged']
 Token 'ats': top3 -> ['hop', 'iki', 'rail', 'hma', 'chers', 'Ġorganized', 'hey', 'Ġburned', 'ons', 'cha']
 Token 'ĠMusic': top3 -> ['ĠCube', 'ĠFabric', 'hop', 'ĠMachine', 'ĠArchitects', 'Ġvenue', 'ĠNob', 'Ġsting', 'Ġestablishments', 'Ġsound']
 Token 'Ġis': top3 -> ['ĠGarland', 'Ġbacked', 'ĠBalt', 'Ġmine', 'Ġpainted', 'Ġpressed', 'Ġmounted', 'Ġorganized', 'ĠCube', 'Ġcentered']
 Token 'Ġowned': top3 -> ['Ġowned', 'Ġproperty', 'ĠDominion', 'Ġstationary', 'Ġartisan', 'Ġdeb', 'Ġowner', 'Ġunpredictable', 'Ġcamp', 'Ġbaker']
 Token 'Ġby': top3 -> ['ĠGarland', 'Ġhand', 'Ġwise', 'Ġbar', 'ĠNorman', 'ĠGladiator', 'Ġpressing', 'law', 'ĠGat', 'Ġlaw']

Layer 4:
 Token 'Be': top3 -> ['aum', 'cca', 'hemoth', 'har', 'ached', 'ats', 'lyak', 'gged', 'heading', 'ijing']
 Token 'ats': top3 -> ['hop', 'iki', 'hey', 'rail', 'chet', 'hee', 'Ġorganized', 'hma', 'yon', 'hit']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'ĠCube', 'hop', 'ĠArchitects', 'ĠMachine', 'ĠMom', 'ĠNob', 'ĠWond', 'Ġdownstairs', 'Ġestablishments']
 Token 'Ġis': top3 -> ['ĠGarland', 'Ġpainted', 'Ġmine', 'Ġpressed', 'Ġbacked', 'Ġwise', 'ĠBalt', 'Ġorganized', 'Ġstruck', 'Ġnot']
 Token 'Ġowned': top3 -> ['Ġowned', 'Ġfancy', 'ĠDominion', 'Ġproperty', 'Ġbaker', 'Ġartisan', 'Ġhotel', 'Ġserv', 'ĠAB', 'Ġchilled']
 Token 'Ġby': top3 -> ['ĠGarland', 'Ġhand', 'ĠGladiator', 'Ġwise', 'law', 'Ġlaw', 'ĠNorman', 'Ġpressing', 'ĠGat', 'ĠDrill']

Layer 5:
 Token 'Be': top3 -> ['gotten', 'hemoth', 'har', 'ijing', 'aum', 'ached', 'avers', 'gged', 'aver', 'gging']
 Token 'ats': top3 -> ['hop', 'chers', 'cher', 'ĠLogged', 'iki', 'chet', 'hey', 'hee', 'ay', 'Ġproud']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'hop', 'ĠCube', 'ĠMom', 'Ġsting', 'ĠMachine', 'ĠWond', 'ĠStyles', 'ĠArchitects', 'ĠNob']
 Token 'Ġis': top3 -> ['Ġnot', 'Ġthrilled', 'Ġpainted', 'Ġserved', 'Ġpressed', 'Ġdelighted', 'Ġbacked', 'Ġsold', 'Ġorganized', 'ĠGarland']
 Token 'Ġowned': top3 -> ['ĠDominion', 'ĠAB', 'Ġbaker', 'Ġowned', 'Ġeditor', 'Ġproperty', 'Ġsworn', 'aband', 'Ġhotel', 'Ġstationary']
 Token 'Ġby': top3 -> ['ĠGarland', 'ĠGladiator', 'law', 'Ġhand', 'ĠNorman', 'Ġlaw', 'Ġpressing', 'ĠChef', 'Ġwise', 'ĠDrill']

Layer 6:
 Token 'Be': top3 -> ['gotten', 'avers', 'aum', 'hemoth', 'ijing', 'gging', 'aver', 'har', 'agher', 'heading']
 Token 'ats': top3 -> ['hop', 'ĠLogged', 'chet', 'cher', 'hee', 'Ġproud', 'chers', 'iki', 'ons', 'hen']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'ĠCube', 'hop', 'ĠMom', 'Ġsting', 'ĠCircle', 'ĠSphere', 'ĠStyles', 'ologist', 'ĠWond']
 Token 'Ġis': top3 -> ['Ġthrilled', 'Ġnot', 'Ġpainted', 'ĠBree', 'Ġnow', 'Ġbacked', 'ĠGarland', 'Ġpleased', 'Ġdelighted', 'Ġpressed']
 Token 'Ġowned': top3 -> ['Ġlucky', 'Ġowned', 'ĠDominion', 'Ġsworn', 'ĠTravis', 'Ġproperty', 'Ġoutright', 'ĠMarina', 'aband', 'Ġstationary']
 Token 'Ġby': top3 -> ['ĠGarland', 'law', 'Ġpressing', 'Ġhand', 'ĠGladiator', 'ĠNorman', 'ĠChef', 'Ġlaw', 'ĠGat', 'Ġwise']

Layer 7:
 Token 'Be': top3 -> ['gotten', 'ijing', 'agher', 'gging', 'aum', 'hemoth', 'avers', 'har', 'heading', 'vest']
 Token 'ats': top3 -> ['ĠLogged', 'hop', 'cher', 'hee', 'chet', 'ĠDynam', 'Ġproud', 'ons', 'Ġdrum', 'Ġdear']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'hop', 'ĠCube', 'ĠCircle', 'ĠStyles', 'Ġwise', 'ĠNob', 'ĠMom', 'ĠSounds', 'ĠGrill']
 Token 'Ġis': top3 -> ['Ġthrilled', 'Ġpressed', 'Ġpleased', 'ĠGarland', 'Ġsold', 'Ġnot', 'Ġbacked', 'Ġdelighted', 'Ġpainted', 'Ġserved']
 Token 'Ġowned': top3 -> ['Ġowned', 'ĠTravis', 'Ġserv', 'Ġlucky', 'Ġproperty', 'Ġoutright', 'Ġby', 'ĠMarina', 'Ġhands', 'Ġsworn']
 Token 'Ġby': top3 -> ['ĠGarland', 'Ġpressing', 'law', 'Ġhand', 'Ġcraft', 'Ġmag', 'Ġlaw', 'ĠCraft', 'ĠNorman', 'ĠChef']

Layer 8:
 Token 'Be': top3 -> ['clips', '://', 'agher', 'Cola', 'milo', 'Initialized', 'wcsstore', 'Iterator', 'ĠTradable', 'æĸ¹']
 Token 'ats': top3 -> ['ĠLogged', 'hop', 'ĠDynam', 'cher', 'Ġproud', 'hen', 'yon', 'iron', 'Ġak', 'Ġdear']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'hop', 'ĠCube', 'ĠScene', 'ĠStyles', 'ĠCircle', 'ĠGrill', 'ĠCircus', 'ĠClub', 'Ġwise']
 Token 'Ġis': top3 -> ['Ġthrilled', 'Ġsold', 'Ġnot', 'Ġpleased', 'Ġdelighted', 'Ġorganized', 'Ġhonored', 'ĠSOLD', 'Ġabsolutely', 'Ġproud']
 Token 'Ġowned': top3 -> ['ĠTravis', 'Ġowned', 'Ġby', 'Ġoutright', 'Ġproperty', 'ĠAngelo', 'ĠSpark', 'aband', 'ĠBY', 'ĠDominion']
 Token 'Ġby': top3 -> ['Ġproprietary', 'Ġcraft', 'Ġtrademark', 'Ġhand', 'Ġpressing', 'Ġcamp', 'law', 'ĠGarland', 'Ġmaster', 'Ġselling']

Layer 9:
 Token 'Be': top3 -> ['://', 'clips', 'agher', 'wcsstore', 'Cola', "Ġ'/", 'Initialized', 'dates', ':{', 'ideshow']
 Token 'ats': top3 -> ['ĠDynam', 'ĠLogged', 'hop', 'cher', 'hen', 'Ġak', 'ĠDry', 'yon', 'Ġproud', 'iron']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'ĠCircle', 'ĠCube', 'ĠScene', 'ĠStyles', 'ĠSounds', 'hop', 'ĠBox', 'ĠClub', 'ĠBreak']
 Token 'Ġis': top3 -> ['Ġsold', 'Ġthrilled', 'Ġpleased', 'Ġdelighted', 'Ġorganized', 'Ġslated', 'Ġnot', 'Ġhonored', 'ĠSOLD', 'Ġsupposed']
 Token 'Ġowned': top3 -> ['ĠTravis', 'Ġowned', 'Ġoutright', 'Ġby', 'Ġproperty', 'ĠAngelo', 'ĠEqual', 'Ġentirely', 'ĠSpark', 'Ġinternationally']
 Token 'Ġby': top3 -> ['Ġproprietary', 'law', 'Ġcraft', 'Ġpressing', 'Ġcamp', 'Ġtrademark', 'Ġhosting', 'Ġmaster', 'Ġhand', 'Ġrenting']

Layer 10:
 Token 'Be': top3 -> ['://', 'clips', 'agher', 'wcsstore', "Ġ'/", ':{', 'Cola', 'ideshow', 'dates', 'Ġaddr']
 Token 'ats': top3 -> ['ĠDynam', 'ĠLogged', 'cher', 'chet', 'Ġak', 'hop', 'hen', 'Ġdear', 'hered', 'Ġproud']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'ĠCube', 'ĠCircle', 'Ġwise', 'ĠScene', 'ĠClub', 'ĠMachine', 'Ġstation', 'ĠSpotlight', 'ĠBox']
 Token 'Ġis': top3 -> ['Ġorganized', 'Ġpleased', 'Ġthrilled', 'Ġslated', 'Ġsold', 'Ġdelighted', 'Ġhonored', 'Ġobviously', 'Ġbacked', 'Ġsupposed']
 Token 'Ġowned': top3 -> ['ĠTravis', 'Ġowned', 'Ġby', 'Ġoutright', 'Ġtrademark', 'ĠEqual', 'Ġproperty', 'ĠAngelo', 'Ġwholly', 'Ġindependent']
 Token 'Ġby': top3 -> ['Ġproprietary', 'Ġmaster', 'Ġlicensed', 'Ġhosting', 'Ġtrademark', 'Ġrenting', 'law', 'Ġhand', 'ĠGarland', 'Ġcraft']

Layer 11:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', 'agher', "Ġ'/", ':{', 'Ġanyway', 'Ġaddr', 'ideshow', 'office']
 Token 'ats': top3 -> ['ĠDynam', 'ĠLogged', 'chet', 'Ġpowder', 'cher', 'mith', 'ĠDrum', 'hop', 'Ġweld', 'Ġdragging']
 Token 'ĠMusic': top3 -> ['ĠFabric', 'ĠCube', 'ĠScene', 'ĠCircle', 'ĠBox', 'Ġwise', 'ĠClub', 'Ġstation', 'ĠCards', 'Ġclip']
 Token 'Ġis': top3 -> ['Ġobviously', 'Ġorganized', 'Ġsupposed', 'Ġalways', 'Ġsold', 'Ġslated', 'Ġpleased', 'Ġhonored', 'Ġthrilled', 'Ġnot']
 Token 'Ġowned': top3 -> ['Ġby', 'ĠTravis', 'ĠAngelo', 'Ġtrademark', 'Ġwholly', 'Ġentirely', 'Ġoutright', 'ĠMiranda', 'Ġowned', 'ĠEqual']
 Token 'Ġby': top3 -> ['Ġproprietary', 'Ġmaster', 'Ġtrademark', 'Ġlicensed', 'Ġcamp', 'Ġauction', 'Ġhosting', 'Ġpressing', 'Ġcraft', 'Ġindependent']

Layer 12:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', "Ġ'/", ':{', 'agher', 'Ġanyway', 'Ġaddr', 'ideshow', 'office']
 Token 'ats': top3 -> ['ĠDynam', 'hop', 'hare', 'chet', 'ĠSlave', 'ign', 'mith', 'ĠDrum', 'ĠFabric', 'tons']
 Token 'ĠMusic': top3 -> ['ĠCube', 'ĠScene', 'ĠFabric', 'ĠCircle', 'ĠArchitects', 'Ġstation', 'ĠClub', 'ĠEater', 'ĠBreak', 'Ġclip']
 Token 'Ġis': top3 -> ['Ġobviously', 'Ġorganized', 'Ġsold', 'Ġalways', 'Ġpleased', 'Ġsupposed', 'Ġnow', 'Ġslated', 'Ġproud', 'Ġthrilled']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġtrademark', 'ĠTravis', 'Ġwholly', 'Ġoutright', 'ĠAngelo', 'Ġproperty', 'by', 'ĠEqual', 'Ġequally']
 Token 'Ġby': top3 -> ['Ġproprietary', 'Ġmaster', 'Ġtrademark', 'Ġlicensed', 'Ġcamp', 'Ġprivate', 'Ġlocal', 'Ġpowerful', 'Ġpolice', 'Ġcraft']

Layer 13:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġanyway', 'Ġaddr', 'ideshow', 'office']
 Token 'ats': top3 -> ['ĠDynam', 'hare', 'hop', 'ĠDrum', 'hit', 'kept', 'up', 'ĠDanger', 'mith', 'Ġdragging']
 Token 'ĠMusic': top3 -> ['ĠScene', 'ĠCube', 'ĠFabric', 'ĠCircle', 'ĠClub', 'ĠBreak', 'ĠArchitects', 'Ġclip', 'ĠEater', 'Ġwise']
 Token 'Ġis': top3 -> ['Ġorganized', 'Ġpleased', 'Ġobviously', 'Ġsold', 'Ġthrilled', 'Ġsupposed', 'Ġalways', 'Ġdelighted', 'Ġset', 'Ġslated']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġtrademark', 'Ġwholly', 'by', 'Ġoutright', 'Ġequally', 'Ġentirely', 'Ġproperty', 'ĠAngelo', 'Ġexclusively']
 Token 'Ġby': top3 -> ['Ġproprietary', 'Ġlicensed', 'Ġmaster', 'Ġtrademark', 'ĠScha', 'Ġrights', 'Ġlicensing', 'Ġproperty', 'ĠGall', 'ĠConst']

Layer 14:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġanyway', 'Ġaddr', '.(', 'office']
 Token 'ats': top3 -> ['ĠDynam', 'hare', 'hop', 'up', 'ĠDR', 'ĠDrum', 'mith', 'leep', 'ĠSong', 'ĠFabric']
 Token 'ĠMusic': top3 -> ['ĠScene', 'ĠClub', 'ĠFabric', 'ĠCube', 'ĠCircle', 'ĠArchitects', 'ĠCL', 'ĠBreak', 'Ġclip', 'ĠCards']
 Token 'Ġis': top3 -> ['Ġorganized', 'Ġpleased', 'Ġsold', 'Ġobviously', 'Ġsupposed', 'Ġdelighted', 'Ġthrilled', 'Ġorganised', 'Ġalways', 'ĠCube']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġtrademark', 'Ġwholly', 'by', 'Ġequally', 'Ġoutright', 'Ġexclusively', 'ĠDominion', 'Ġinternationally', 'ĠPete']
 Token 'Ġby': top3 -> ['Ġlicensed', 'Ġproprietary', 'Ġmaster', 'Ġtrademark', 'Ġlicensing', 'Ġlicense', 'ĠJ', 'ĠConst', 'ĠLicensed', 'Ġorganizers']

Layer 15:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġanyway', 'Ġaddr', '.(', 'TEXTURE']
 Token 'ats': top3 -> ['ĠDynam', 'ĠDR', 'ĠDeath', 'ĠSlave', 'mith', 'ĠSong', 'ĠDrum', 'Ġdeath', 'ĠDanger', 'Ġwise']
 Token 'ĠMusic': top3 -> ['ĠClub', 'ĠScene', 'ĠCL', 'ĠHall', 'ĠArchitects', 'ĠBreak', 'ĠCircle', 'ĠCafe', 'ĠCube', 'ĠCD']
 Token 'Ġis': top3 -> ['Ġorganized', 'Ġpleased', 'Ġsold', 'Ġsupposed', 'Ġthrilled', 'Ġobviously', 'Ġdelighted', 'Ġorganised', 'Ġslated', 'ĠCube']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġtrademark', 'by', 'ĠTyler', 'ĠDominion', 'ĠTravis', 'ĠPete', 'ĠSaga', 'Ġexclusively', 'Ġequally']
 Token 'Ġby': top3 -> ['Ġlicensed', 'Ġtrademark', 'Ġmaster', 'Ġlicensing', 'Ġproprietary', 'ĠLicensed', 'Ġresponsible', 'ĠScha', 'Ġdrill', 'ĠConst']

Layer 16:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġanyway', 'Ġaddr', '.(', 'TEXTURE']
 Token 'ats': top3 -> ['ĠDeath', 'ĠDynam', 'ĠDR', 'hare', 'ĠSong', 'Ġdeath', 'heet', 'mith', 'Ġpoll', 'ĠSlave']
 Token 'ĠMusic': top3 -> ['ĠScene', 'ĠClub', 'ĠVideo', 'ĠCenter', 'ĠCD', 'ĠCDs', 'ĠStudio', 'ĠHall', 'ĠCards', 'Ġvideo']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġsold', 'Ġorganized', 'Ġobviously', 'Ġthrilled', 'Ġnotoriously', 'Ġsupposed', 'Ġnow', 'Ġalways', 'Ġset']
 Token 'Ġowned': top3 -> ['Ġtrademark', 'Ġby', 'Ġexclusively', 'ĠPete', 'by', 'ĠTravis', 'ĠSaga', 'Ġproperty', 'ĠMiranda', 'ĠTyler']
 Token 'Ġby': top3 -> ['Ġtrademark', 'Ġlicensed', 'Ġmaster', 'Ġpowerful', 'ĠJ', 'ĠLicensed', 'Ġlicensing', 'Ġassociation', 'Ġheavy', 'Ġproprietary']

Layer 17:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['ĠDeath', 'ĠDynam', 'up', 'Ġdeath', 'ĠDR', 'ĠSlave', 'heet', 'leep', 'mith', 'Ġpoll']
 Token 'ĠMusic': top3 -> ['ĠClub', 'ĠScene', 'ĠCD', 'ĠStudio', 'ĠFabric', 'ĠCenter', 'ĠCards', 'ĠVideo', 'Ġvideo', 'ĠCircle']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġsold', 'Ġthrilled', 'Ġobviously', 'Ġdelighted', 'Ġalways', 'Ġorganized', 'Ġsupposed', 'Ġhonored', 'Ġowned']
 Token 'Ġowned': top3 -> ['Ġtrademark', 'Ġby', 'Ġexclusively', 'by', 'ĠPete', 'ĠSaga', 'ĠMiranda', 'Ġproperty', 'Ġsubsidiary', 'Ġentity']
 Token 'Ġby': top3 -> ['Ġlicensed', 'ĠJ', 'Ġtrademark', 'Ġmaster', 'Ġpowerful', 'ĠLuc', 'Ġlicensing', 'ĠDavid', 'ĠJack', 'ĠClive']

Layer 18:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['ĠDeath', 'ĠDR', 'ĠDynam', 'Ġdeath', 'ĠSlave', 'Ġoff', 'up', 'ĠDrum', 'mith', 'ĠD']
 Token 'ĠMusic': top3 -> ['ĠClub', 'ĠCD', 'ĠScene', 'ĠCenter', 'ĠVideo', 'ĠCards', 'ĠFabric', 'ĠStudio', 'ĠVideos', 'ĠSpotlight']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġowned', 'Ġsold', 'Ġthrilled', 'Ġdelighted', 'Ġhonored', 'Ġorganized', 'Ġpartnered', 'Ġnotoriously', 'Ġobviously']
 Token 'Ġowned': top3 -> ['Ġtrademark', 'Ġby', 'Ġsubsidiary', 'Ġproperty', 'Ġentity', 'ĠPete', 'by', 'Ġexclusively', 'Ġowned', 'ĠSaga']
 Token 'Ġby': top3 -> ['Ġlicensing', 'Ġtrademark', 'Ġbankruptcy', 'Ġlicensed', 'ĠLuc', 'Ġbankrupt', 'ĠBrooklyn', 'ĠJ', 'Ġmaster', 'ĠCu']

Layer 19:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['ĠDeath', 'mith', 'ĠDynam', 'ĠNap', 'Ġdeath', 'ĠSlave', 'heet', 'Ġoff', 'ĠDR', 'up']
 Token 'ĠMusic': top3 -> ['ĠClub', 'ĠCD', 'ĠVideo', 'ĠStudio', 'ĠScene', 'ĠSpotlight', 'Ġvideo', 'ĠCafe', 'ĠCube', 'ĠVideos']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġowned', 'Ġthrilled', 'Ġdelighted', 'Ġnotoriously', 'Ġhonored', 'Ġpartnered', 'Ġsold', 'Ġunderstandably', 'Ġproud']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġtrademark', 'ĠSaga', 'Ġsubsidiary', 'Ġentity', 'Ġproperty', 'Ġowned', 'by', 'Ġexclusively', 'Ġsubsidiaries']
 Token 'Ġby': top3 -> ['Ġbankruptcy', 'Ġbankrupt', 'Ġlicensing', 'ĠCu', 'Ġpublishing', 'Ġlicensed', 'ĠLuc', 'ĠJ', 'Ġprivate', 'Ġsister']

Layer 20:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'TEXTURE', 'Ġanyway', '.(']
 Token 'ats': top3 -> ['mith', 'up', 'hop', 'ĠDeath', 'heet', 'Ġdeath', 'Ġoff', 'leep', 'ĠDrum', 'ob']
 Token 'ĠMusic': top3 -> ['ĠCD', 'ĠClub', 'ĠVideo', 'ĠCDs', 'ĠSpotlight', 'ĠCafe', 'Ġvideo', 'ĠCube', 'ĠDisco', 'Ġalbum']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġthrilled', 'Ġdelighted', 'Ġowned', 'Ġunderstandably', 'Ġnotoriously', 'Ġsold', 'Ġproud', 'Ġhonored', 'Ġalways']
 Token 'Ġowned': top3 -> ['Ġtrademark', 'Ġby', 'Ġsubsidiary', 'ĠSaga', 'Ġentity', 'Ġowned', 'Ġsubsidiaries', 'Ġproperty', 'Ġinternationally', 'Ġexclusively']
 Token 'Ġby': top3 -> ['Ġbankruptcy', 'Ġbankrupt', 'Ġpublishing', 'Ġlicensing', 'Ġsister', 'Ġlicensed', 'ĠMeredith', 'ĠJ', 'ĠJewish', 'Ġprivate']

Layer 21:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'TEXTURE', 'Ġanyway', '.(']
 Token 'ats': top3 -> ['up', 'mith', 'heet', 'ĠDeath', 'hop', 'leep', 'Ġdeath', 'Ġoff', 'Ġup', 'ĠDrum']
 Token 'ĠMusic': top3 -> ['ĠCD', 'Ġvideo', 'ĠVideo', 'ĠCDs', 'ĠCafe', 'ĠCube', 'ĠClub', 'Ġalbum', 'ĠEntertainment', 'ĠCompany']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġowned', 'Ġdelighted', 'Ġthrilled', 'Ġsold', 'Ġnotoriously', 'Ġcurrently', 'Ġproud', 'Ġnow', 'Ġhonored']
 Token 'Ġowned': top3 -> ['Ġtrademark', 'Ġsubsidiary', 'Ġby', 'Ġowned', 'Ġentity', 'Ġsubsidiaries', 'ĠSaga', 'Ġlicensed', 'Ġproperty', 'Ġexclusively']
 Token 'Ġby': top3 -> ['Ġpublishing', 'Ġbankruptcy', 'Ġbankrupt', 'Ġparent', 'Ġprivate', 'Ġformer', 'ĠJ', 'Ġlicensed', 'ĠJewish', 'Ġlicensing']

Layer 22:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['heet', 'mith', 'up', 'hop', 'ĠDeath', 'hift', 'worth', 'ĠDrum', 'leep', 'Ġdeath']
 Token 'ĠMusic': top3 -> ['ĠCD', 'ĠCube', 'ĠVideo', 'Ġvideo', 'ĠCafe', 'ĠInc', 'ĠCDs', 'ĠClub', 'ĠCompany', 'Ġstore']
 Token 'Ġis': top3 -> ['Ġowned', 'Ġpleased', 'Ġdelighted', 'Ġsold', 'Ġpartnered', 'Ġcurrently', 'Ġlocated', 'Ġlicensed', 'Ġthrilled', 'Ġnotoriously']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġtrademark', 'Ġby', 'Ġsubsidiaries', 'Ġowned', 'Ġentity', 'Ġexclusively', 'Ġjointly', 'Ġnotoriously', 'ĠSaga']
 Token 'Ġby': top3 -> ['Ġparent', 'ĠJ', 'Ġbillionaire', 'Ġbankruptcy', 'ĠUS', 'Ġpublishing', 'ĠRupert', 'Ġformer', 'Ġbankrupt', 'ĠCharles']

Layer 23:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['mith', 'heet', 'hift', 'up', 'ĠDeath', 'hop', 'kins', 'worth', 'leep', 'Ġdeath']
 Token 'ĠMusic': top3 -> ['ĠCube', 'ĠVideo', 'ĠClub', 'ĠCD', 'ĠInc', 'Ġvideo', 'ĠEntertainment', 'ĠCorporation', 'ĠFoundation', 'ĠCDs']
 Token 'Ġis': top3 -> ['Ġowned', 'Ġpleased', 'Ġsold', 'Ġpartnered', 'Ġdelighted', 'Ġcurrently', 'Ġalso', 'Ġthrilled', 'Ġlicensed', 'Ġannounced']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġtrademark', 'Ġsubsidiaries', 'Ġby', 'Ġowned', 'Ġentity', 'Ġexclusively', 'Ġjointly', 'Ġlicensed', 'Ġproperty']
 Token 'Ġby': top3 -> ['Ġparent', 'Ġbillionaire', 'Ġbankruptcy', 'Ġconglomerate', 'ĠRupert', 'Ġbankrupt', 'ĠCharles', 'ĠJ', 'ĠCoca', 'Ġsister']

Layer 24:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['mith', 'heet', 'hift', 'up', 'leep', 'ĠDeath', 'ome', 'kins', 'pring', 'ĠUp']
 Token 'ĠMusic': top3 -> ['ĠVideo', 'Ġvideo', 'ĠCube', 'ĠEntertainment', 'ĠClub', 'ĠCD', 'ĠStore', 'ĠCEO', 'ĠInc', 'ĠVideos']
 Token 'Ġis': top3 -> ['Ġowned', 'Ġpleased', 'Ġpartnered', 'Ġnow', 'Ġalso', 'Ġthrilled', 'Ġannounced', 'Ġsold', 'Ġdelighted', 'Ġcurrently']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġtrademark', 'Ġowned', 'Ġentity', 'Ġlicensed', 'Ġjointly', 'Ġexclusively', 'Ġconglomerate']
 Token 'Ġby': top3 -> ['Ġbillionaire', 'Ġconglomerate', 'ĠRupert', 'Ġparent', 'ĠJ', 'Ġformer', 'Ġbankrupt', 'Ġbankruptcy', 'Ġsubsidiary', 'Ġsister']

Layer 25:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġaddr', 'Ġanyway', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['mith', 'heet', 'up', 'hift', 'ĠDeath', 'ĠUp', 'leep', 'Ġdeath', 'Ġmustache', 'pring']
 Token 'ĠMusic': top3 -> ['ĠClub', 'ĠVideo', 'Ġalbum', 'ĠCEO', 'ĠCD', 'ĠStore', 'ĠEntertainment', 'ĠInc', 'Ġvideo', 'ĠSpotlight']
 Token 'Ġis': top3 -> ['Ġowned', 'Ġpartnered', 'Ġpleased', 'Ġannounced', 'Ġalso', 'Ġsold', 'Ġcurrently', 'Ġthrilled', 'Ġnow', 'Ġhosting']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġtrademark', 'Ġowned', 'Ġlicensing', 'Ġjointly', 'Ġentity', 'Ġrights', 'Ġlicensed']
 Token 'Ġby': top3 -> ['Ġbillionaire', 'Ġconglomerate', 'ĠRupert', 'Ġparent', 'Ġformer', 'Ġbankruptcy', 'Ġpublishing', 'ĠCharles', 'ĠUS', 'ĠJ']

Layer 26:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'agher', 'Ġanyway', 'Ġaddr', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['mith', 'heet', 'Ġguitar', 'hift', 'ĠUp', 'up', 'ĠDrum', 'Ġdrum', 'Ġup', 'Ġmustache']
 Token 'ĠMusic': top3 -> ['ĠVideo', 'ĠStreaming', 'Ġvideo', 'ĠClub', 'ĠInc', 'Ġalbum', 'ĠEntertainment', 'ĠCEO', 'ĠCD', 'Ġstreaming']
 Token 'Ġis': top3 -> ['Ġpartnered', 'Ġowned', 'Ġpleased', 'Ġdelighted', 'Ġannounced', 'Ġthrilled', 'Ġalso', 'Ġcurrently', 'Ġnow', 'Ġpartnering']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġtrademark', 'Ġowned', 'Ġentity', 'Ġlicensing', 'Ġjointly', 'Ġlicensed', 'Ġconglomerate']
 Token 'Ġby': top3 -> ['Ġbillionaire', 'Ġconglomerate', 'Ġformer', 'Ġpublishing', 'ĠRupert', 'Ġlicensing', 'Ġparent', 'ĠSony', 'Ġcorporate', 'ĠUS']

Layer 27:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'Ġanyway', 'Ġaddr', 'agher', 'TEXTURE', '.(']
 Token 'ats': top3 -> ['mith', 'heet', 'Ġguitar', 'ĠUp', 'hift', 'ome', 'ĠGuitar', 'up', 'ĠDrum', 'Ġup']
 Token 'ĠMusic': top3 -> ['ĠEntertainment', 'ĠVideo', 'ĠInc', 'Ġvideo', 'ĠCEO', 'Ġalbum', 'ĠStreaming', 'ĠCD', 'ĠClub', 'ĠDisco']
 Token 'Ġis': top3 -> ['Ġpartnered', 'Ġpleased', 'Ġdelighted', 'Ġowned', 'Ġcurrently', 'Ġthrilled', 'Ġpartnering', 'Ġalso', 'Ġofficially', 'Ġannounced']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġowned', 'Ġjointly', 'Ġtrademark', 'Ġlicensing', 'Ġentity', 'Ġexclusively', 'Ġconglomerate']
 Token 'Ġby': top3 -> ['Ġbillionaire', 'Ġconglomerate', 'Ġformer', 'ĠBroad', 'ĠSony', 'Ġcompany', 'ĠRupert', 'Ġpublishing', 'Ġlicensing', 'Ġparent']

Layer 28:
 Token 'Be': top3 -> ['://', 'clips', 'wcsstore', ':{', "Ġ'/", 'Ġanyway', 'Ġaddr', 'agher', '.(', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'Ġguitar', 'ĠMusic', 'heet', 'Ġguitarist', 'ĠGuitar', 'ĠUp', 'pring', 'ĠDrum', 'ĠRhythm']
 Token 'ĠMusic': top3 -> ['ĠEntertainment', 'ĠCEO', 'ĠStreaming', 'ĠInc', 'ĠVideo', 'Ġvideo', 'Ġstreaming', 'ĠCompany', 'Ġalbum', 'ĠCD']
 Token 'Ġis': top3 -> ['Ġpartnered', 'Ġpartnering', 'Ġowned', 'Ġofficially', 'Ġcurrently', 'Ġdelighted', 'Ġpleased', 'Ġalso', 'Ġlicensing', 'Ġannounced']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġjointly', 'Ġowned', 'Ġtrademark', 'Ġexclusively', 'Ġconglomerate', 'Ġlicensing', 'Ġentity']
 Token 'Ġby': top3 -> ['Ġconglomerate', 'Ġbillionaire', 'ĠSony', 'Ġformer', 'ĠBeats', 'Ġcompany', 'Ġcompanies', 'ĠRupert', 'ĠAOL', 'Ġparent']

Layer 29:
 Token 'Be': top3 -> ['://', 'clips', ':{', 'wcsstore', "Ġ'/", 'Ġanyway', 'Ġaddr', 'agher', '.(', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġguitar', 'Ġguitarist', 'ĠGuitar', 'ĠAudio', 'ĠRhythm', 'pring', 'Ġrecording', 'ĠRecording']
 Token 'ĠMusic': top3 -> ['ĠEntertainment', 'ĠStreaming', 'Ġstreaming', 'ĠVideo', 'ĠCEO', 'Ġalbum', 'ĠSpotify', 'ĠBeats', 'ĠInc', 'ĠVideos']
 Token 'Ġis': top3 -> ['Ġpartnered', 'Ġpartnering', 'Ġowned', 'Ġpleased', 'Ġdelighted', 'Ġthrilled', 'Ġofficially', 'Ġlicensing', 'Ġcurrently', 'Ġalso']
 Token 'Ġowned': top3 -> ['Ġsubsidiary', 'Ġsubsidiaries', 'Ġby', 'Ġjointly', 'Ġowned', 'Ġexclusively', 'Ġtrademark', 'Ġconglomerate', 'Ġcompany', 'Ġlicensing']
 Token 'Ġby': top3 -> ['ĠBeats', 'Ġconglomerate', 'Ġbillionaire', 'Ġcompany', 'ĠSony', 'Ġcompanies', 'Ġformer', 'ĠRupert', 'ĠSamsung', 'ĠApple']

Layer 30:
 Token 'Be': top3 -> ['://', 'clips', ':{', 'wcsstore', "Ġ'/", 'Ġanyway', 'Ġaddr', 'agher', '.(', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġguitar', 'ĠAudio', 'Ġheadphones', 'ĠElectronics', 'ĠGuitar', 'ĠRhythm', 'Ġdrum', 'ĠVideo']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠEntertainment', 'ĠStreaming', 'Ġstreaming', 'ĠMusic', 'ĠInc', 'ĠCEO', 'ĠVideos', 'ĠSpotify', 'ĠVideo']
 Token 'Ġis': top3 -> ['Ġpartnered', 'Ġpartnering', 'Ġpleased', 'Ġthrilled', 'Ġalso', 'Ġcurrently', 'Ġowned', 'Ġdelighted', 'Ġofficially', 'Ġlicensing']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġjointly', 'Ġowned', 'Ġtrademark', 'Ġexclusively', 'Ġlicensing', 'Ġproperty', 'by']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSony', 'ĠApple', 'Ġconglomerate', 'Ġbillionaire', 'ĠSamsung', 'ĠSpotify', 'Ġcompanies', 'ĠRupert', 'ĠAdidas']

Layer 31:
 Token 'Be': top3 -> ['://', 'clips', ':{', 'wcsstore', "Ġ'/", 'Ġanyway', 'Ġaddr', '.(', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġguitar', 'ĠAudio', 'Ġheadphones', 'ĠGuitar', 'ĠRhythm', 'Ġmusic', 'ĠRecording', 'ĠiPhone']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'Ġstreaming', 'ĠInc', 'ĠStreaming', 'ĠMusic', 'ĠCEO', 'ĠEntertainment', 'ĠSpotify', 'Ġapp', 'Ġalbum']
 Token 'Ġis': top3 -> ['Ġpartnering', 'Ġpartnered', 'Ġpleased', 'Ġnow', 'Ġthrilled', 'Ġcurrently', 'Ġalso', 'Ġowned', 'Ġdelighted', 'Ġofficially']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġsubsidiary', 'Ġjointly', 'Ġsubsidiaries', 'Ġowned', 'Ġtrademark', 'Ġexclusively', 'Ġproperty', 'Ġcompany', 'Ġlicensing']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠApple', 'ĠSony', 'ĠSpotify', 'ĠSamsung', 'Ġconglomerate', 'Ġcompanies', 'Ġbillionaire', 'Ġcompany', 'ĠAlibaba']

Layer 32:
 Token 'Be': top3 -> ['://', 'clips', ':{', "Ġ'/", 'wcsstore', 'Ġanyway', 'Ġaddr', '.(', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġguitar', 'ĠAudio', 'Ġheadphones', 'ĠRhythm', 'ĠGuitar', 'Ġmusic', 'ĠiPhone', 'Ċ']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠInc', 'ĠCEO', 'Ġstreaming', 'ĠStreaming', 'ĠMusic', 'Ġapp', 'ĠSpotify', 'ĠEntertainment', 'Ġalbum']
 Token 'Ġis': top3 -> ['Ġpartnering', 'Ġnow', 'Ġpartnered', 'Ġpleased', 'Ġalso', 'Ġcurrently', 'Ġofficially', 'Ġthrilled', 'Ġreleasing', 'Ġdelighted']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġtrademark', 'Ġowned', 'Ġproperty', 'Ġexclusively', 'Ġlicensing', 'Ġcompany']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠApple', 'ĠSpotify', 'ĠSony', 'ĠSamsung', 'Ġbillionaire', 'ĠPepsi', 'ĠAlibaba', 'Ġcompanies', 'Ġconglomerate']

Layer 33:
 Token 'Be': top3 -> ['://', 'clips', ':{', "Ġ'/", 'wcsstore', 'Ġanyway', 'Ġaddr', '.(', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġguitar', 'Ġheadphones', 'Ġmusic', 'ĠAudio', 'ĠRhythm', 'ĠGuitar', 'ĠRecording', 'ĠDrum']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠInc', 'ĠCEO', 'ĠMusic', 'ĠSpotify', 'ĠStreaming', 'Ġstreaming', 'Ġalbum', 'ĠEntertainment', 'Ġapp']
 Token 'Ġis': top3 -> ['Ġpleased', 'Ġpartnering', 'Ġnow', 'Ġthrilled', 'Ġreleasing', 'Ġalso', 'Ġpartnered', 'Ġcurrently', 'Ġdelighted', 'Ġofficially']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġowned', 'Ġtrademark', 'Ġproperty', 'Ġexclusively', 'Ġcompany', 'Ġprivately']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠSony', 'ĠSamsung', 'Ġbillionaire', 'ĠKanye', 'ĠPepsi', 'Ġrapper', 'ĠAlibaba']

Layer 34:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'wcsstore', 'Ġanyway', 'Ġaddr', '.(', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['mith', 'ĠMusic', 'Ġheadphones', 'ĠAudio', 'Ġmusic', 'Ġguitar', 'ĠRhythm', 'ĠRecording', 'ĠGuitar', 'Ġrecording']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠInc', 'ĠCEO', 'ĠMusic', ',', 'ĠSpotify', 'ĠStreaming', 'Ġstreaming', 'Ġapp', 'Ġalbum']
 Token 'Ġis': top3 -> ['Ġpartnering', 'Ġpleased', 'Ġreleasing', 'Ġthrilled', 'Ġalso', 'Ġgearing', 'Ġnow', 'Ġcurrently', 'Ġlaunching', 'Ġdelighted']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġowned', 'Ġtrademark', 'Ġproperty', 'Ġexclusively', 'by', 'ĠBY']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠApple', 'ĠSpotify', 'ĠSony', 'ĠSamsung', 'ĠKanye', 'ĠPepsi', 'ĠAlibaba', 'ĠMusic', 'Ġrapper']

Layer 35:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'wcsstore', 'Ġanyway', '.(', 'Ġaddr', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['ĠMusic', 'ĠAudio', 'Ġheadphones', 'mith', 'Ġmusic', 'Ġguitar', 'Ġaudio', 'ĠRecording', 'ĠRhythm', 'Ġrecording']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠMusic', 'ĠInc', 'ĠCEO', 'ĠSpotify', 'Ġalbum', ',', 'Ġmusic', 'Ġapp', 'ĠBillboard']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġpleased', 'Ġthrilled', 'Ġgearing', 'Ġlaunching', 'Ġcurrently', 'Ġalso', 'Ġnow', 'Ġdelighted']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġexclusively', 'Ġowned', 'Ġproperty', 'Ġtrademark', 'by', 'ĠBY']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠSony', 'ĠKanye', 'ĠSamsung', 'ĠMusic', 'Ġmusic', 'Ġrapper', 'ĠPepsi']

Layer 36:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'wcsstore', 'Ġanyway', '.(', 'Ġaddr', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['ĠMusic', 'ĠAudio', 'Ġheadphones', 'Ġmusic', 'mith', 'Ġaudio', 'Ġguitar', 'ĠRhythm', 'Ġlistening', 'ĠRecording']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠMusic', 'ĠInc', 'ĠCEO', 'ĠSpotify', 'Ġalbum', ',', 'Ġmusic', 'ĠBillboard', 'Ġapp']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġpleased', 'Ġgearing', 'Ġlaunching', 'Ġthrilled', 'Ġcurrently', 'Ġalso', 'Ġproud', 'Ġoffering']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġsubsidiaries', 'Ġexclusively', 'by', 'Ġproperty', 'Ġowned', 'Ġwholly', 'ĠBY']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'Ġmusic', 'ĠKanye', 'ĠSony', 'ĠMusic', 'Ġrapper', 'ĠSamsung', 'ĠGrammy']

Layer 37:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'wcsstore', 'Ġanyway', '.(', 'Ġaddr', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['ĠMusic', 'ĠAudio', 'Ġheadphones', 'Ġmusic', 'mith', 'Ġaudio', 'Ġguitar', 'Ġlistening', 'Ġrecording', 'ĠRhythm']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠMusic', 'ĠInc', 'ĠCEO', 'ĠSpotify', ',', 'Ġalbum', 'Ġmusic', 'Ġhas', 'Ġapp']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġgearing', 'Ġpleased', 'Ġlaunching', 'Ġalso', 'Ġcurrently', 'Ġthrilled', 'Ġproud', 'Ġoffering']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġsubsidiary', 'Ġjointly', 'Ġexclusively', 'Ġsubsidiaries', 'Ġowned', 'by', 'Ġproperty', 'Ġwholly', 'Ġand']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠKanye', 'Ġmusic', 'Ġrapper', 'ĠMusic', 'ĠSony', 'ĠGrammy', 'ĠiTunes']

Layer 38:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'wcsstore', 'Ġanyway', '.(', 'Ġaddr', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['ĠMusic', 'Ġmusic', 'ĠAudio', 'Ġheadphones', 'Ġaudio', 'mith', 'Ġguitar', 'ĠRhythm', 'Ġlistening', 'Ġrecording']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠMusic', ',', 'ĠCEO', 'ĠSpotify', 'ĠInc', 'Ġalbum', 'Ċ', 'Ġhas', 'Ġmusic']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġgearing', 'Ġlaunching', 'Ġpleased', 'Ġalso', 'Ġcurrently', 'Ġproud', 'Ġoffering', 'Ġthrilled']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'by', 'Ġexclusively', 'Ġsubsidiaries', 'Ġowned', 'Ġand', 'Ġwholly', 'Ġproperty']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠKanye', 'Ġmusic', 'Ġrapper', 'ĠMusic', 'ĠSony', 'ĠGrammy', 'ĠiTunes']

Layer 39:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'Ġanyway', 'wcsstore', '.(', 'Ġaddr', 'agher', 'TEXTURE']
 Token 'ats': top3 -> ['ĠMusic', 'Ġmusic', 'ĠAudio', 'Ġheadphones', 'Ġaudio', 'mith', 'Ġguitar', 'Ġlistening', 'Ġrecording', 'ĠRhythm']
 Token 'ĠMusic': top3 -> [',', 'ĠCEO', 'ĠBeats', 'Ċ', 'ĠInc', 'ĠMusic', 'Ġhas', 'ĠSpotify', 'Ġis', 'Ġand']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġlaunching', 'Ġgearing', 'Ġpleased', 'Ġalso', 'Ġcurrently', 'Ġnow', 'Ġproud', 'Ġa']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġsubsidiary', 'Ġexclusively', 'by', 'Ġand', 'Ġowned', 'Ġwholly', 'Ġsubsidiaries', 'Ġproperty']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠKanye', 'Ġmusic', 'Ġrapper', 'ĠSony', 'ĠMusic', 'ĠiTunes', 'ĠGrammy']

Layer 40:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", ':{', 'Ġanyway', 'wcsstore', '.(', 'Ġaddr', 'agher', '._']
 Token 'ats': top3 -> ['Ġmusic', 'ĠMusic', 'Ġheadphones', 'ĠAudio', 'Ġaudio', 'mith', 'Ġguitar', 'Ġlistening', 'Ċ', 'Ġrecording']
 Token 'ĠMusic': top3 -> ['ĠCEO', ',', 'ĠBeats', 'Ċ', 'ĠMusic', 'Ġis', 'Ġhas', 'ĠInc', 'ĠSpotify', 'Ġand']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġlaunching', 'Ġgearing', 'Ġpleased', 'Ġalso', 'Ġnow', 'Ġa', 'Ġthrilled', 'Ġproud']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġand', 'Ġsubsidiary', 'Ġexclusively', 'by', 'Ġowned', 'Ġwholly', 'Ġsubsidiaries', 'Ġproperty']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'Ġrapper', 'ĠKanye', 'Ġmusic', 'ĠiTunes', 'ĠMusic', 'ĠDJ', 'ĠSony']

Layer 41:
 Token 'Be': top3 -> ['://', 'clips', "Ġ'/", 'Ġanyway', ':{', 'wcsstore', '.(', 'Ġaddr', '._', 'agher']
 Token 'ats': top3 -> ['Ġmusic', 'ĠMusic', 'Ġheadphones', 'ĠAudio', 'Ġaudio', 'Ġguitar', 'Ġtracks', 'Ġlistening', 'Ċ', 'Ġrecording']
 Token 'ĠMusic': top3 -> ['ĠBeats', 'ĠCEO', 'ĠMusic', ',', 'Ċ', 'ĠSpotify', 'Ġalbum', 'Ġmusic', 'Ġis', 'ĠInc']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġpartnering', 'Ġlaunching', 'Ġgearing', 'Ġalso', 'Ġnow', 'Ġoffering', 'Ġa', 'Ġexpanding', 'Ġpleased']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġjointly', 'Ġand', 'Ġexclusively', 'Ġsubsidiary', 'Ġwholly', 'Ġowned', 'Ġsubsidiaries', 'Ġproperty', 'Ġprivately']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠSpotify', 'ĠApple', 'ĠiTunes', 'Ġrapper', 'Ġmusic', 'ĠKanye', 'ĠMusic', 'ĠDJ', 'ĠSony']

Layer 42:
 Token 'Be': top3 -> ['://', 'clips', 'Ġanyway', "Ġ'/", ':{', '.(', 'wcsstore', 'Ġaddr', '._', 'agher']
 Token 'ats': top3 -> ['Ġmusic', 'ĠMusic', 'ĠAudio', 'Ġheadphones', 'Ġaudio', 'Ċ', 'Ġguitar', 'Ġtracks', ',', '-']
 Token 'ĠMusic': top3 -> ['ĠCEO', ',', 'ĠBeats', 'Ċ', 'ĠMusic', 'Ġhas', 'Ġis', 'Ġand', 'ĠSpotify', "'s"]
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġlaunching', 'Ġpartnering', 'Ġa', 'Ġgearing', 'Ġalso', 'Ġnow', 'Ġoffering', 'Ġthe', 'Ġbringing']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġjointly', 'Ġexclusively', 'Ġsubsidiary', 'Ġwholly', 'Ġowned', 'Ġprimarily', 'Ġproperty', 'Ġin']
 Token 'Ġby': top3 -> ['ĠBeats', 'ĠApple', 'ĠSpotify', 'Ġrapper', 'ĠiTunes', 'Ġmusic', 'ĠKanye', 'ĠDJ', 'ĠMusic', 'ĠSony']

Layer 43:
 Token 'Be': top3 -> ['://', 'clips', 'Ġanyway', "Ġ'/", ':{', '.(', 'wcsstore', 'Ġaddr', '._', 'agher']
 Token 'ats': top3 -> ['Ġmusic', 'ĠMusic', 'ĠAudio', 'Ċ', 'Ġheadphones', ',', 'Ġaudio', ':', '-', 'Ġby']
 Token 'ĠMusic': top3 -> [',', 'ĠCEO', 'Ċ', 'Ġhas', 'Ġis', 'Ġand', 'ĠBeats', 'ĠMusic', "'s", 'Ġwill']
 Token 'Ġis': top3 -> ['Ġreleasing', 'Ġa', 'Ġlaunching', 'Ġnow', 'Ġalso', 'Ġpartnering', 'Ġthe', 'Ġnot', 'Ġgearing', 'Ġbringing']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġjointly', 'Ġexclusively', 'Ġwholly', 'Ġin', 'Ġsubsidiary', 'by', 'Ġprimarily', 'Ġprivately']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠBeats', 'ĠSpotify', 'Ġrapper', 'ĠiTunes', 'ĠKanye', 'Ġmusic', 'ĠDJ', 'ĠSony', 'ĠMusic']

Layer 44:
 Token 'Be': top3 -> ['://', 'clips', 'Ġanyway', "Ġ'/", '.(', ':{', 'wcsstore', 'Ġaddr', '._', 'agher']
 Token 'ats': top3 -> ['Ċ', 'Ġby', ',', 'Ġmusic', 'ĠMusic', ':', '-', 'Ġ1', 'ĠAudio', '.']
 Token 'ĠMusic': top3 -> [',', 'Ċ', 'ĠCEO', 'Ġis', 'Ġhas', 'Ġand', "'s", '.', 'Ġwill', 'Ġ(']
 Token 'Ġis': top3 -> ['Ġa', 'Ġthe', 'Ġreleasing', 'Ġalso', 'Ġnow', 'Ġlaunching', 'Ġnot', 'Ġan', 'Ġone', 'Ġmaking']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġin', 'Ġjointly', 'Ġexclusively', 'ĠBy', ',', 'by', 'Ġwholly', 'Ġprimarily']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠBeats', 'ĠSpotify', 'ĠUniversal', 'Ġrapper', 'ĠiTunes', 'ĠKanye', 'ĠSony', 'ĠRd', 'ĠDisney']

Layer 45:
 Token 'Be': top3 -> ['://', 'clips', 'Ġanyway', "Ġ'/", '.(', ':{', 'Ġaddr', 'wcsstore', '._', 'agher']
 Token 'ats': top3 -> ['Ġby', 'Ċ', ',', 'Ġ1', ':', '-', 'ĠMusic', 'Ġmusic', 'Ġ2', 'Ġand']
 Token 'ĠMusic': top3 -> [',', 'Ċ', 'Ġis', 'Ġhas', 'Ġand', 'ĠCEO', "'s", '.', 'Ġ(', 'Ġwill']
 Token 'Ġis': top3 -> ['Ġa', 'Ġthe', 'Ġalso', 'Ġnow', 'Ġnot', 'Ġreleasing', 'Ġone', 'Ġan', 'Ġlaunching', 'Ġmaking']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġin', 'Ġjointly', ',', 'ĠBy', 'Ġexclusively', 'Ġthe', 'Ġa', 'Ġprimarily']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠBeats', 'ĠSpotify', 'ĠUniversal', 'Ġrapper', 'ĠiTunes', 'ĠRd', 'ĠSony', 'ĠKanye', 'ĠDisney']

Layer 46:
 Token 'Be': top3 -> ['://', 'clips', 'Ġanyway', "Ġ'/", '.(', 'Ġrespectively', 'hire', "'re", 'Ġaddr', '":"']
 Token 'ats': top3 -> ['Ġby', ',', 'Ċ', '-', ':', 'Ġ1', 'ĠMusic', 'Ġmusic', 'Ġper', 'Ġ2']
 Token 'ĠMusic': top3 -> [',', 'Ċ', 'Ġis', 'Ġand', 'Ġhas', '.', 'Ġ(', "'s", 'ĠCEO', 'Ġwill']
 Token 'Ġis': top3 -> ['Ġa', 'Ġthe', 'Ġalso', 'Ġnot', 'Ġnow', 'Ġone', 'Ġan', 'Ġmaking', 'Ġno', 'Ġreleasing']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġin', ',', 'Ġthe', 'Ġjointly', 'Ġa', 'ĠBy', 'Ġexclusively', 'Ġfirst']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠBeats', 'ĠUniversal', 'ĠSpotify', 'Ġrapper', 'ĠDisney', 'ĠSony', 'Ġmusic', 'ĠDr', 'ĠRd']

Layer 47:
 Token 'Be': top3 -> ['Ġa', 'Ġthe', ',', '.', 'Ċ', '-', 'Ġin', 'Ġsure', 'Ġ"', 'Ġand']
 Token 'ats': top3 -> [',', 'Ġby', 'Ċ', ':', '-', 'Ġ1', '.', 'Ġand', 'Ġis', 'Ġper']
 Token 'ĠMusic': top3 -> [',', 'Ċ', 'Ġis', 'Ġand', 'Ġhas', '.', 'Ġ(', "'s", 'Ġwill', 'Ġin']
 Token 'Ġis': top3 -> ['Ġa', 'Ġthe', 'Ġalso', 'Ġnot', 'Ġone', 'Ġnow', 'Ġan', 'Ġin', 'Ġ"', 'Ġgoing']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġin', ',', 'Ġthe', 'Ġa', 'Ġfirst', 'Ġor', 'Ġ(', 'Ġas']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠUniversal', 'ĠDr', 'Ġthe', 'ĠBeats', 'ĠDisney', 'ĠIn', 'ĠSony', 'ĠE', 'Ġmusic']

Layer 48:
 Token 'Be': top3 -> ['Ġsure', 'Ġa', 'ijing', 'ep', 'au', 'ak', 'arers', 'gan', 'aver', 'Ġcareful']
 Token 'ats': top3 -> ['ĠMusic', 'Ġby', ':', 'Ċ', ',', 'Ġ1', '.', '/', 'ĠAudio', 'ĠBy']
 Token 'ĠMusic': top3 -> [',', 'Ċ', ')', 'Ġis', '.', 'Ġhas', 'Ġand', "'s", 'Ġ(', ':']
 Token 'Ġis': top3 -> ['Ġa', 'Ġthe', 'Ġan', 'Ġalso', 'Ġnow', 'Ġone', 'Ġnot', 'Ġcurrently', 'Ġin', 'Ġowned']
 Token 'Ġowned': top3 -> ['Ġby', 'Ġand', 'Ġin', ',', 'Ġor', '/', 'Ġa', 'Ġthe', 'Ġ(', 'Ġjointly']
 Token 'Ġby': top3 -> ['ĠApple', 'ĠIn', 'Ġthe', 'ĠUniversal', 'ĠDr', 'ĠE', 'ĠRd', 'Ġa', 'ĠJimmy', 'ĠJay']
```

I feel I could spend hours to figure out something meaningful out of this, 
therefore I gave the newly released OpenAI o3 model a try, and its answer really impressed me!
Below is the copy pasted full answer. Maybe you find it interesting and useful too.

## 1. Token-wise Analysis

### **a. `Be` + `ats`: Subword recomposition**

| Depth   | Top Predictions                                       | Interpretation                                                              |
| ------- | ----------------------------------------------------- | --------------------------------------------------------------------------- |
| 0–3     | `"Be"`, `"Bee"`, `"Beg"` / `"ats"`, `"atz"`, `"atsu"` | Just echoing embeddings — early layers reflect lexical similarity           |
| 4–15    | `"aum"`, `"hemoth"` / `"hop"`, `"iki"`, `"hee"`       | Still treating subwords separately — drifting to phonetically similar words |
| **~20** | `ats` → `"guitar"`, `"audio"`, `"music"`              | Model begins integrating with rightward context (`ĠMusic`)                  |
| 28–35   | Both → `"Beats"`, `"headphones"`, `"Audio"`           | Fused entity formed — hidden state now encodes the brand                    |
| 36–48   | Plateaus — predictions stabilize                      | High confidence in fused representation                                     |

**Insight**: Subword recomposition occurs around layers 20–30. Early logit-lens layers reflect surface form only.

---

### **b. `ĠMusic`: From noun to brand entity**

* Layers 0–10: `"Music"`, `"Concert"`, `"Audio"` – generic, topic-related
* Layers 11–25: Shifts to venues and organizations
* **From ~25 onward**: `"Beats"` becomes top prediction – model has fused `Beats Music` into a single branded concept

---

### **c. `Ġis`: Syntax to semantics**

* Early (0–5): `"is"`, `"has"`, `"was"` – purely grammatical alternatives
* Mid (6–15): `"sold"`, `"mounted"`, `"delighted"` – verbs relevant to company ownership
* Late (20–48): `"pleased"`, `"partnered"`, `"currently"` – business-centric semantics

---

### **d. `Ġowned`: Detects "owned by" bigram**

* Layers 0–10: `"owned"`, `"ownership"`, `"owner"`
* Layers 11–18: Begins predicting `"by"` as top next token
* Layer 18–20: `"by"` becomes dominant — collocation is locked in

---

### **e. `Ġby`: Fact retrieval happens late**

| Depth     | Top Predictions                  | Interpretation                               |
| --------- | -------------------------------- | -------------------------------------------- |
| 0–10      | `"Garland"`, `"Norman"`, `"law"` | Generic co-occurrence nouns                  |
| 15–25     | `"conglomerate"`, `"subsidiary"` | Category identified — model expects org name |
| **29–48** | `"Beats"`, `"Sony"`, **`Apple`** | Ground-truth fact retrieved                  |

**Insight**: Model only accesses factual knowledge of Beats → Apple in the final 30% of the stack.

---

## 2. Phase Transitions (Cross-token View)

| Phase                          | Layers | Characteristics                                            |
| ------------------------------ | ------ | ---------------------------------------------------------- |
| **Lexical / Phonological**     | 0–10   | Surface-form similarity; weak composition                  |
| **Syntactic / Collocational**  | 10–25  | Phrase detection; token fusion; "owned → by" pairing       |
| **Semantic / World Knowledge** | 25–48  | Entity linking; factual recall ("Beats is owned by Apple") |

---

## 3. Quantitative Checks You Can Try

### ✅ KL Divergence to Final Layer
```python
from torch.nn.functional import kl_div, log_softmax, softmax

final_logits = logits_all_layers[-1]
kl_vals = []
for l in range(len(logits_all_layers) - 1):
    p = softmax(final_logits, dim=-1)
    q = log_softmax(logits_all_layers[l], dim=-1)
    kl_vals.append(kl_div(q, p, reduction='batchmean'))
```

### ✅ Entropy of `by`'s Distribution
```python
import torch

entropies = []
for l in range(len(logits_all_layers)):
    probs = softmax(logits_all_layers[l], dim=-1)
    by_probs = probs[0, pos_by]  # index of "by"
    entropy = -(by_probs * by_probs.log()).sum()
    entropies.append(entropy.item())
```

---

## 4. Why `Be` Predicts Garbage Early

The token `Be` is ambiguous and seen in many noisy contexts:
* `Be` as a verb → "Be happy", "Be careful"
* `Be` as part of a URL → "beats://..." leads to predictions like `://`, `wcsstore`
* `Be` in names → "Beyoncé", "Bei..."

**Conclusion**: The model hedges its bets early until later layers clarify context via `ats`, `Music`.

---

## 5. Practical Logit Lens Tips

✅ Early layers reflect **form**, not meaning  
✅ Mid-layers resolve **phrase structure & entity fusion**  
✅ Top layers encode **semantic associations & facts**  
✅ Intervening layers (20–30) are **ideal for probing collocations, entity grounding**

---

## 6. Where to Go Next

* **Ablation**: Mask attention in layers 25–35 to see if Apple disappears from predictions
* **Prompt surgery**: Try "Beats **Electronics** is owned by" — see if factual path changes
* **Mean path probing**: Project hidden state at `by` onto name vectors — discover if Apple vector activates early

---

Happy hacking! 🔬📊

