# LlamaIndex Knowledge Assistant

A full-stack application that lets you query your documents using LlamaIndex and React.

## Overview

This project creates a knowledge base from your documents and provides a natural language interface to query them. It uses:

- **Backend**: Python, Flask, LlamaIndex, OpenAI
- **Frontend**: React, Axios, React-Markdown

## Project Structure

```
llamaindex-knowledge-assistant/
├── backend/                    # Flask API with LlamaIndex
│   ├── data/                   # Your documents go here
│   ├── knowledge_assistant.py  # Backend server code
│   ├── requirements.txt        # Python dependencies
│   └── README.md               # Backend documentation
│
├── frontend/                   # React frontend application
│   ├── public/                 # Static files
│   ├── src/                    # React source code
│   ├── package.json            # Frontend dependencies
│   └── .gitignore              # Frontend gitignore
│
├── README.md                   # Main documentation
├── setup.sh                    # Setup script (optional)
└── .gitignore                  # Main gitignore
```

## Getting Started

### Prerequisites

- Python 3.8+
- Node.js 14+
- OpenAI API key

### Setup and Running

#### Backend

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Add your documents to the `backend/data` directory

4. Set your OpenAI API key:
```bash
export OPENAI_API_KEY="your-api-key-here"
# OR edit knowledge_assistant.py
```

5. Start the backend server:
```bash
python knowledge_assistant.py
```

The API will be available at http://localhost:5000

#### Frontend

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install Node.js dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

The application will be available at http://localhost:3000

## Features

- Upload and process various document formats
- Natural language querying of your documents
- Source attribution for answers
- Modern, responsive UI
- Markdown support for rich text

## License

MIT

## Author

Milad Nasiri
