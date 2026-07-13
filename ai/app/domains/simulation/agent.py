from langchain_ollama import ChatOllama
import prompts
from langchain_core.messages import SystemMessage, HumanMessage


llm = ChatOllama(
    model="llama3.1:8b",
    temperature=1.0,
    reasoning=False
)


while True:
    user = input("사용자: ")

    if user == "exit":
        break

    print(prompts.PROSECUTOR_SCAM_PROMPT)

    response = llm.invoke([
        SystemMessage(
            content=prompts.PROSECUTOR_SCAM_PROMPT
        ),
        HumanMessage(
            content=user
        )
    ])

    print("AI:", response.content)

import prompts

print(prompts.__file__)