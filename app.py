#----INTERNAL MODEL FUNCTIONS---------------------------
import torch
from transformers import (AutoModelForCausalLM, AutoTokenizer,
                          GenerationConfig, set_seed)

# globals: device ; tokenizer ; generation_config ; model 
def load_model():
    global device
    device = "cuda" if torch.cuda.is_available() else "cpu"
    global tokenizer
    tokenizer = AutoTokenizer.from_pretrained("HuggingFaceH4/starchat-alpha") #args.model_id, revision=args.revision)
    print(f"Special tokens: {tokenizer.special_tokens_map}")
    print(f"EOS token ID for generation: {tokenizer.convert_tokens_to_ids('<|end|>')}")
    global generation_config
    generation_config = GenerationConfig(
        temperature=0.2,
        top_k=50,
        top_p=0.95,
        repetition_penalty=1.2,
        do_sample=True,
        pad_token_id=tokenizer.eos_token_id,
        eos_token_id=tokenizer.convert_tokens_to_ids("<|end|>"),
        min_new_tokens=32,
        max_new_tokens=256,
    )
    global model
    model = AutoModelForCausalLM.from_pretrained(
        "HuggingFaceH4/starchat-alpha", load_in_8bit=True, device_map="auto", torch_dtype=torch.float16
    )

def do_inference(user_message):
    prompt = f"<|system|>\n<|end|>\n<|user|>{user_message}<|end|>\n<|assistant|>"
    batch = tokenizer(prompt, return_tensors="pt", return_token_type_ids=False).to(device)
    generated_ids = model.generate(**batch, generation_config=generation_config)
    generated_text = tokenizer.decode(generated_ids[0], skip_special_tokens=False).lstrip()
    return generated_text

#--------------------------------------------------------------------------------
# API functions

from flask import Flask, request, jsonify

app = Flask(__name__)

#set up model
load_model()

def get_bot_response(user_message):
    return do_inference(user_message)

#=======================================================================================
# Instructions/help
@app.route('/')
def api_help():
    return 'API for starchat-service, see https://github.com/aolney/starchat-service'

# get_bot_response(user_message)
@app.route('/api/getBotResponse', methods=['GET', 'POST'])
def api_getBotResponse():
content = request.get_json()
result = get_bot_response( content['user_message'] )
return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')