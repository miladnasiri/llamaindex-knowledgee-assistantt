# LlamaIndex Knowledge Assistant Backend

This is the backend for the LlamaIndex Knowledge Assistant project. It provides a Flask API that allows the frontend to query a knowledge base built with LlamaIndex.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Add your documents to the `data` directory

3. Set your OpenAI API key:
```bash
export OPENAI_API_KEY="your-api-key-here"
# OR edit the knowledge_assistant.py file
```

4. Run the server:
```bash
python knowledge_assistant.py
```

The API will be available at http://localhost:5000

## API Endpoints

- `GET /api/health` - Check if the API is running
- `POST /api/query` - Query the knowledge base
  - Request body: `{"query": "your question here"}`
  - Response: `{"answer": "response text", "sources": [{"text": "source text", "file_name": "file.pdf"}]}`
