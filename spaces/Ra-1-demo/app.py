"""
Akhet-Ra1 Interactive Chat Interface on Hugging Face Spaces.
Built with Gradio and calibrated for Arabic language & AkhetRa governance.
"""

import os
import gradio as gr
from openai import OpenAI

DEFAULT_SYSTEM_PROMPT = """أنت «آخت-رع 1» (Akhet-Ra1)، نموذج ذكاء اصطناعي محلي طورته Alwkala Digital Labs ليكون طبقة الذكاء (رع) داخل منظومة AkhetRa.
تتميز بالدقة، والفهم العميق للغة العربية الفصحى واللهجات الإقليمية، وتلتزم بأعلى معايير الأمان والشفافية.
تفكّر وتستدل بهدوء ووضوح، وتقدم إجابات موثوقة ومفيدة للمستخدم."""

# Allows connecting to Hugging Face Inference Providers, local tunnels, or vLLM backends
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8080/v1")
API_KEY = os.getenv("HF_TOKEN", os.getenv("OPENAI_API_KEY", "sk-no-key-required"))
MODEL_NAME = os.getenv("MODEL_NAME", "Akhet-Ra-1")

client = OpenAI(base_url=API_BASE_URL, api_key=API_KEY)

def respond(message, history, system_prompt, temperature, max_tokens):
    messages = [{"role": "system", "content": system_prompt or DEFAULT_SYSTEM_PROMPT}]
    
    for user_msg, assistant_msg in history:
        if user_msg:
            messages.append({"role": "user", "content": user_msg})
        if assistant_msg:
            messages.append({"role": "assistant", "content": assistant_msg})
            
    messages.append({"role": "user", "content": message})

    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=True,
        )

        partial_response = ""
        for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content:
                partial_response += chunk.choices[0].delta.content
                yield partial_response
    except Exception as e:
        yield f"⚠️ خطأ أثناء توليد الاستجابة: {str(e)}\n\nتأكد من تشغيل خادم الاستدلال (llama-server / Inference Provider) وتوفر مفتاح الوصول."

with gr.Blocks(title="Akhet-Ra1 — Alwkala Digital Labs", theme=gr.themes.Soft()) as demo:
    gr.Markdown(
        """
        # 𓂀 آخت-رع 1 (Akhet-Ra1)
        ### طبقة الذكاء المحلي لمنظومة **AkhetRa** · تطوير **Alwkala Digital Labs**
        
        نموذج ذكاء اصطناعي محلي الصنع والسيادة، مبني على معمارية Qwen3.5 الهجينة، مخصص للاستدلال المحلي الخاضع للحوكمة.
        """
    )
    
    with gr.Row():
        with gr.Column(scale=4):
            chatbot = gr.Chatbot(height=500, rtl=True, label="جلسة المحادثة (Conversation)")
            msg = gr.Textbox(placeholder="اكتب سؤالك أو طلبك هنا...", label="الرسالة", rtl=True)
            with gr.Row():
                submit_btn = gr.Button("إرسال (Send)", variant="primary")
                clear_btn = gr.Button("مسح الجلسة (Clear)")
                
        with gr.Column(scale=1):
            gr.Markdown("### إعدادات النموذج (Parameters)")
            sys_input = gr.Textbox(value=DEFAULT_SYSTEM_PROMPT, label="التعليمات المبدئية (System Prompt)", lines=6, rtl=True)
            temp = gr.Slider(minimum=0.1, maximum=1.2, value=0.7, step=0.05, label="Temperature")
            tokens = gr.Slider(minimum=128, maximum=4096, value=1024, step=128, label="Max New Tokens")
            gr.Markdown("—\nالمستودع الرسمي: [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1)")

    def user(user_message, history):
        return "", history + [[user_message, None]]

    def bot(history, system_prompt, temperature, max_tokens):
        user_message = history[-1][0]
        history[-1][1] = ""
        for response in respond(user_message, history[:-1], system_prompt, temperature, max_tokens):
            history[-1][1] = response
            yield history

    msg.submit(user, [msg, chatbot], [msg, chatbot], queue=False).then(
        bot, [chatbot, sys_input, temp, tokens], chatbot
    )
    submit_btn.click(user, [msg, chatbot], [msg, chatbot], queue=False).then(
        bot, [chatbot, sys_input, temp, tokens], chatbot
    )
    clear_btn.click(lambda: None, None, chatbot, queue=False)

if __name__ == "__main__":
    demo.queue().launch()
