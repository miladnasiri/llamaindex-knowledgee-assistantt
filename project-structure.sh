#!/bin/bash

# Navigate to your project directory
cd ~/Desktop/llamaindex-knowledge-assistant

# Create the basic project structure
mkdir -p backend/data backend/storage frontend/public frontend/src/components frontend/src/styles

# Create backend files
cat > backend/knowledge_assistant.py << 'EOL'
# LlamaIndex Knowledge Base Assistant
# A simple Q&A system that leverages your own documents

import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings
from llama_index.llms.openai import OpenAI
from llama_index.core import PromptTemplate

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Set your OpenAI API key
os.environ["OPENAI_API_KEY"] = "your-api-key-here"

# Configure the LLM
Settings.llm = OpenAI(model="gpt-3.5-turbo")

def load_data():
    """Load documents from the 'data' directory."""
    if not os.path.exists("data"):
        os.makedirs("data")
        print("Created 'data' directory. Please add your documents there and run again.")
        return None
    
    documents = SimpleDirectoryReader("data").load_data()
    print(f"Loaded {len(documents)} documents from 'data' directory")
    return documents

def create_index(documents):
    """Create a vector store index from the documents."""
    index = VectorStoreIndex.from_documents(documents)
    # Save the index for future use
    index.storage_context.persist("storage")
    return index

def load_index():
    """Load an existing index from storage if it exists."""
    from llama_index.core import StorageContext, load_index_from_storage
    if not os.path.exists("storage"):
        return None
    
    storage_context = StorageContext.from_defaults(persist_dir="storage")
    index = load_index_from_storage(storage_context)
    return index

def setup_custom_prompt():
    """Set up a custom prompt template for improved responses."""
    qa_template = PromptTemplate(
        """You are a helpful AI assistant that answers questions based on the provided context.
        Be concise, accurate, and helpful. If you don't know the answer or can't find it in the context, say so.
        
        Context: {context_str}
        
        Question: {query_str}
        
        Answer: """
    )
    return qa_template

def get_query_engine():
    # Try to load existing index or create a new one
    index = load_index()
    if index is None:
        documents = load_data()
        if documents is None:
            return None
        index = create_index(documents)
    
    # Create a query engine with our custom prompt
    qa_template = setup_custom_prompt()
    query_engine = index.as_query_engine(text_qa_template=qa_template)
    return query_engine

@app.route('/api/query', methods=['POST'])
def query():
    data = request.json
    user_query = data.get('query', '')
    
    if not user_query:
        return jsonify({"error": "Query is required"}), 400
    
    query_engine = get_query_engine()
    if query_engine is None:
        return jsonify({"error": "No documents found. Please add documents to the data directory."}), 500
    
    response = query_engine.query(user_query)
    
    sources = [
        {"text": node.node.get_text(), "file_name": node.node.metadata.get('file_name', 'unknown')}
        for node in response.source_nodes
    ]
    
    return jsonify({
        "answer": response.response,
        "sources": sources
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    app.run(debug=True, port=5000)
EOL

cat > backend/requirements.txt << 'EOL'
llama-index==0.10.13
llama-index-llms-openai==0.1.5
openai==1.13.3
pypdf==4.0.1
flask==2.3.3
flask-cors==4.0.0
EOL

cat > backend/README.md << 'EOL'
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
EOL

cat > backend/.gitignore << 'EOL'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Environment
.env
.venv
env/
venv/
ENV/

# Project specific
storage/
data/

# API keys
.env
EOL

# Create a sample text file for the knowledge base
mkdir -p backend/data
cat > backend/data/sample.txt << 'EOL'
# LlamaIndex Knowledge Base

LlamaIndex is a data framework for LLM applications to ingest, structure, and access private or domain-specific data. It was created by Jerry Liu in late 2022.

## Key Features

1. Data Ingestion: LlamaIndex helps you ingest your existing data from different sources and formats.
2. Data Indexing: It allows you to structure your data in a format that's easy for LLMs to consume.
3. Query Interface: It provides a natural language interface for querying your data.
4. Multimodal Support: LlamaIndex can handle text, images, and other data types.

## Use Cases

- Building a chatbot that can answer questions about your company's documentation
- Creating a search engine for your personal notes
- Generating reports based on your private data
- Analyzing large datasets with natural language queries

## Getting Started

To use LlamaIndex, you first need to install it via pip:
```
pip install llama-index
```

Then you can create a simple document index:
```python
from llama_index import SimpleDirectoryReader, GPTVectorStoreIndex

documents = SimpleDirectoryReader('data').load_data()
index = GPTVectorStoreIndex.from_documents(documents)
```

## Advanced Features

LlamaIndex also supports more advanced features like:
- Custom chunking strategies
- Different embedding models
- Query engines for specialized tasks
- Integration with other tools and frameworks
EOL

# Create front-end files
# package.json
cat > frontend/package.json << 'EOL'
{
  "name": "llamaindex-knowledge-assistant-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.6.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-markdown": "^9.0.1",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "proxy": "http://localhost:5000"
}
EOL

# public files
cat > frontend/public/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="LlamaIndex Knowledge Assistant - Query your documents with AI"
    />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>LlamaIndex Knowledge Assistant</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOL

cat > frontend/public/manifest.json << 'EOL'
{
  "short_name": "Knowledge Assistant",
  "name": "LlamaIndex Knowledge Assistant",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOL

cat > frontend/public/robots.txt << 'EOL'
# https://www.robotstxt.org/robotstxt.html
User-agent: *
Disallow:
EOL

# Create src files
cat > frontend/src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './styles/index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

reportWebVitals();
EOL

cat > frontend/src/App.js << 'EOL'
import React from 'react';
import './styles/App.css';
import QueryInterface from './components/QueryInterface';
import Header from './components/Header';
import Footer from './components/Footer';

function App() {
  return (
    <div className="App">
      <Header />
      <main>
        <QueryInterface />
      </main>
      <Footer />
    </div>
  );
}

export default App;
EOL

cat > frontend/src/reportWebVitals.js << 'EOL'
const reportWebVitals = (onPerfEntry) => {
  if (onPerfEntry && onPerfEntry instanceof Function) {
    import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(onPerfEntry);
      getFID(onPerfEntry);
      getFCP(onPerfEntry);
      getLCP(onPerfEntry);
      getTTFB(onPerfEntry);
    });
  }
};

export default reportWebVitals;
EOL

# Create component files
cat > frontend/src/components/Header.js << 'EOL'
import React from 'react';
import '../styles/Header.css';

function Header() {
  return (
    <header className="header">
      <div className="header-content">
        <h1>LlamaIndex Knowledge Assistant</h1>
        <p>Ask questions about your documents and get AI-powered answers</p>
      </div>
    </header>
  );
}

export default Header;
EOL

cat > frontend/src/components/Footer.js << 'EOL'
import React from 'react';
import '../styles/Footer.css';

function Footer() {
  return (
    <footer className="footer">
      <p>Built with LlamaIndex and React</p>
      <p>
        <a 
          href="https://github.com/miladnasiri/llamaindex-knowledgee-assistantt" 
          target="_blank" 
          rel="noopener noreferrer"
        >
          GitHub Repository
        </a>
      </p>
    </footer>
  );
}

export default Footer;
EOL

cat > frontend/src/components/QueryInterface.js << 'EOL'
import React, { useState } from 'react';
import axios from 'axios';
import ReactMarkdown from 'react-markdown';
import '../styles/QueryInterface.css';

function QueryInterface() {
  const [query, setQuery] = useState('');
  const [answer, setAnswer] = useState('');
  const [sources, setSources] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showSources, setShowSources] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!query.trim()) return;
    
    setLoading(true);
    setError('');
    setAnswer('');
    setSources([]);
    
    try {
      const response = await axios.post('/api/query', { query });
      setAnswer(response.data.answer);
      setSources(response.data.sources || []);
    } catch (err) {
      console.error('Error querying API:', err);
      setError(
        err.response?.data?.error || 
        'Failed to get a response. Make sure the backend server is running.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="query-container">
      <form onSubmit={handleSubmit} className="query-form">
        <div className="input-group">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Ask a question about your documents..."
            className="query-input"
          />
          <button type="submit" className="query-button" disabled={loading}>
            {loading ? 'Asking...' : 'Ask'}
          </button>
        </div>
      </form>

      {loading && (
        <div className="loading">
          <div className="loading-spinner"></div>
          <p>Searching documents and generating answer...</p>
        </div>
      )}

      {error && <div className="error-message">{error}</div>}

      {answer && (
        <div className="answer-container">
          <h2>Answer</h2>
          <div className="answer">
            <ReactMarkdown>{answer}</ReactMarkdown>
          </div>
          
          {sources.length > 0 && (
            <div className="sources">
              <button 
                className="sources-toggle" 
                onClick={() => setShowSources(!showSources)}
              >
                {showSources ? 'Hide Sources' : 'Show Sources'} ({sources.length})
              </button>
              
              {showSources && (
                <div className="sources-list">
                  {sources.map((source, index) => (
                    <div key={index} className="source-item">
                      <div className="source-header">
                        <span className="source-number">Source {index + 1}</span>
                        <span className="source-filename">{source.file_name}</span>
                      </div>
                      <div className="source-text">
                        <ReactMarkdown>{source.text}</ReactMarkdown>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default QueryInterface;
EOL

# Create CSS files
cat > frontend/src/styles/index.css << 'EOL'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f8fa;
  color: #333;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
  background-color: #f1f1f1;
  padding: 2px 4px;
  border-radius: 4px;
}

* {
  box-sizing: border-box;
}
EOL

cat > frontend/src/styles/App.css << 'EOL'
.App {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

main {
  flex: 1;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 20px;
}

@media (max-width: 768px) {
  main {
    padding: 15px;
  }
}
EOL

cat > frontend/src/styles/Header.css << 'EOL'
.header {
  background: linear-gradient(135deg, #4b6cb7 0%, #182848 100%);
  color: white;
  padding: 40px 20px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.header-content {
  max-width: 800px;
  margin: 0 auto;
}

.header h1 {
  font-size: 2.5rem;
  margin: 0 0 10px 0;
}

.header p {
  font-size: 1.2rem;
  margin: 0;
  opacity: 0.9;
}

@media (max-width: 768px) {
  .header {
    padding: 30px 15px;
  }
  
  .header h1 {
    font-size: 2rem;
  }
  
  .header p {
    font-size: 1rem;
  }
}
EOL

cat > frontend/src/styles/Footer.css << 'EOL'
.footer {
  background-color: #f8f9fa;
  border-top: 1px solid #e9ecef;
  padding: 20px;
  text-align: center;
  color: #6c757d;
}

.footer a {
  color: #4b6cb7;
  text-decoration: none;
}

.footer a:hover {
  text-decoration: underline;
}
EOL

cat > frontend/src/styles/QueryInterface.css << 'EOL'
.query-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px 0;
}

.query-form {
  margin-bottom: 30px;
}

.input-group {
  display: flex;
  gap: 10px;
}

.query-input {
  flex: 1;
  padding: 15px;
  font-size: 16px;
  border: 2px solid #ddd;
  border-radius: 8px;
  outline: none;
  transition: border-color 0.3s;
}

.query-input:focus {
  border-color: #4b6cb7;
}

.query-button {
  padding: 0 25px;
  font-size: 16px;
  background-color: #4b6cb7;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.query-button:hover {
  background-color: #3a5a9b;
}

.query-button:disabled {
  background-color: #a0aec0;
  cursor: not-allowed;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 30px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(75, 108, 183, 0.3);
  border-radius: 50%;
  border-top: 4px solid #4b6cb7;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  padding: 15px;
  background-color: #fff5f5;
  color: #c53030;
  border-left: 4px solid #c53030;
  margin: 20px 0;
  border-radius: 4px;
}

.answer-container {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 25px;
  margin-top: 20px;
}

.answer-container h2 {
  margin-top: 0;
  color: #4b6cb7;
  font-size: 1.5rem;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 10px;
}

.answer {
  line-height: 1.6;
}

.sources {
  margin-top: 30px;
}

.sources-toggle {
  background-color: transparent;
  border: 1px solid #4b6cb7;
  color: #4b6cb7;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
}

.sources-toggle:hover {
  background-color: #f0f4ff;
}

.sources-list {
  margin-top: 15px;
  border-top: 1px dashed #e9ecef;
  padding-top: 15px;
}

.source-item {
  background-color: #f8f9fa;
  border-radius: 6px;
  padding: 15px;
  margin-bottom: 15px;
}

.source-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 14px;
}

.source-number {
  font-weight: bold;
  color: #4b6cb7;
}

.source-filename {
  color: #718096;
}

.source-text {
  font-size: 14px;
  border-left: 3px solid #a0aec0;
  padding-left: 12px;
  color: #4a5568;
}

@media (max-width: 768px) {
  .input-group {
    flex-direction: column;
  }
  
  .query-button {
    width: 100%;
    padding: 12px;
  }
  
  .answer-container {
    padding: 15px;
  }
}
EOL

# Create frontend .gitignore
cat > frontend/.gitignore << 'EOL'
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOL

# Create main project files
cat > README.md << 'EOL'
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
EOL

cat > .gitignore << 'EOL'
# Backend
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
backend/storage/

# Frontend
node_modules/
/frontend/build

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Log files
npm-debug.log*
yarn-debug.log*
yarn-error.log*
*.log

# OS specific
.DS_Store
Thumbs.db
EOL

cat > setup.sh << 'EOL'
#!/bin/bash

# Make sure this script is executable:
# chmod +x setup.sh

echo "Setting up LlamaIndex Knowledge Assistant..."

# Setup Backend
echo "Setting up backend..."
cd backend
pip install -r requirements.txt
cd ..

# Setup Frontend
echo "Setting up frontend..."
cd frontend
npm install
cd ..

echo "Setup complete! To run the application:"
echo "1. Set your OpenAI API key in backend/knowledge_assistant.py"
echo "2. Run the backend: python backend/knowledge_assistant.py"
echo "3. Run the frontend: cd frontend && npm start"
echo ""
echo "Happy querying!"
EOL

chmod +x setup.sh

echo "Project structure created successfully!"
