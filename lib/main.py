from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
import os

app = FastAPI()

# Initialize Google Gemini LLM with the API key directly
llm = ChatGoogleGenerativeAI(
    model='gemini-pro',
    google_api_key="AIzaSyBA9PSeg5uzjDLaxY6wzqsnNt0nPQAMwMA"
)

# Create a prompt template for GK questions
my_prompt = PromptTemplate.from_template(
    """You are an AI specifically designed to answer general knowledge (GK) questions.
    Your purpose is to provide clear, accurate, and concise answers to any GK question.
    Only respond to GK-related inquiries.
    Question: {topic}"""
)

# Create the LLMChain with the prompt and LLM
chain = LLMChain(llm=llm, prompt=my_prompt, verbose=False)

class Query(BaseModel):
    topic: str

@app.post("/generate-response")
async def generate_response(query: Query):
    topic = query.topic
    if not topic:
        raise HTTPException(status_code=400, detail="No topic provided")

    try:
        # Generate response
        response = chain.invoke(input=topic)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

    return {"response": response}


@app.get("/")
async def read_root():
    return {"message": "Server is up and running!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
    
# uvicorn lib.main:app --reload --host 0.0.0.0 --port 8000