# 🦙 LlamaIndex Knowledge Assistant

<div align="center">

![LlamaIndex Banner](https://llamahub.ai/images/llama_card.png)

[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)

**Unlock the knowledge hidden in your documents with the power of LLMs**

[Features](#key-features) •
[Demo](#demo-preview) •
[Installation](#installation) •
[Usage](#usage) •
[Architecture](#architecture) •
[Contributing](#contributing) •
[License](#license)

</div>

## 🌟 Overview

LlamaIndex Knowledge Assistant is a sophisticated full-stack application that transforms how you interact with your documents. Built on the powerful [LlamaIndex](https://www.llamaindex.ai/) framework, it enables natural language querying of your personal or professional document collection with AI-generated responses and full source attribution.

The project demonstrates how to integrate LLMs with private data sources to create powerful knowledge retrieval systems that provide accurate, contextual answers directly from your documents.

## 🎥 Demo Preview

![Application Preview](https://github.com/miladnasiri/llamaindex-knowledgee-assistantt/blob/f05c8bff286cf169eeb3ae8fa062b71a89c7d6e5/application-preview.gif)

*The screenshot will be replaced with an actual application screenshot once deployed*

## 🚀 Key Features

- **📄 Multi-format Document Support** - Process PDFs, text files, Markdown, HTML, and more
- **🔍 Vector-based Semantic Search** - Find information based on meaning, not just keywords
- **💬 Conversational Interface** - Ask questions in natural language and receive coherent answers
- **🔗 Source Attribution** - Every answer comes with references to the source documents
- **⚡ High Performance** - Optimized vector storage for fast response times
- **🔄 Real-time Updates** - Add new documents to your knowledge base anytime
- **🎨 Modern, Responsive UI** - Clean interface that works on desktop and mobile
- **🔒 Local Processing** - Your documents stay on your system for privacy

## 🛠️ Architecture

The application follows a modern client-server architecture:

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │      │                 │
│    React UI     │◄────►│   Flask API     │◄────►│  LlamaIndex &   │
│                 │      │                 │      │   OpenAI API    │
│                 │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

- **Frontend**: React application with a responsive UI for querying and displaying results
- **Backend**: Flask API server that processes requests and manages the LlamaIndex interactions
- **Data Processing**: LlamaIndex framework for document ingestion, indexing, and retrieval
- **AI**: Integration with OpenAI's language models for natural language understanding and generation

## 📦 Installation

### Prerequisites

- Python 3.8+
- Node.js 14+
- OpenAI API key
- Git

### Setup Process

1. **Clone the repository**

```bash
git clone https://github.com/miladnasiri/llamaindex-knowledgee-assistantt.git
cd llamaindex-knowledgee-assistantt
```

2. **Backend Setup**

```bash
# Navigate to backend directory
cd backend

# Create and activate virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set your OpenAI API key
# Either edit knowledge_assistant.py or set environment variable:
export OPENAI_API_KEY="your-api-key-here"
```

3. **Frontend Setup**

```bash
# Navigate to frontend directory
cd ../frontend

# Install dependencies
npm install
```

## 🎮 Usage

### Running the Application

1. **Start the backend server**

```bash
# From the backend directory
python knowledge_assistant.py
```

2. **Start the frontend development server**

```bash
# From the frontend directory
npm start
```

3. **Access the application**  
   Open your browser and navigate to: [http://localhost:3000](http://localhost:3000)

### Adding Your Documents

1. Place your documents (PDFs, text files, etc.) in the `backend/data` directory
2. Restart the backend server to index the new documents
3. Start asking questions about your documents!

## 📋 Document Types Supported

- PDF documents (`.pdf`)
- Text files (`.txt`)
- Markdown (`.md`)
- CSV data (`.csv`)
- HTML pages (`.html`)
- JSON files (`.json`)
- And more via LlamaIndex connectors

## 🧩 How It Works

1. **Document Ingestion**: Your documents are loaded and processed into chunks
2. **Embedding Generation**: Text chunks are converted to vector embeddings
3. **Vector Storage**: Embeddings are stored in an efficient vector database
4. **Query Processing**: Your questions are converted to the same vector space
5. **Retrieval**: The most relevant document chunks are retrieved
6. **LLM Response Generation**: OpenAI's models generate coherent answers from the retrieved context
7. **Source Attribution**: The sources used for the answer are tracked and presented

## 🔧 Advanced Configuration

The application can be customized in several ways:

- **Custom Chunking**: Adjust how documents are split in `knowledge_assistant.py`
- **Model Selection**: Change the OpenAI model by modifying the `Settings.llm` line
- **UI Customization**: The React frontend can be styled to match your preferences
- **Embedding Models**: Switch to different embedding models for specialized domains

## 🌐 Deployment

For production deployment:

1. Build the React frontend:
```bash
cd frontend
npm run build
```

2. Serve the backend with a production WSGI server:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 knowledge_assistant:app
```

3. Configure a reverse proxy (Nginx/Apache) to serve the static frontend and proxy API requests

## 🛣️ Roadmap

- [ ] Add user authentication system
- [ ] Implement document upload through UI
- [ ] Add conversation history
- [ ] Support more document types
- [ ] Integrate with cloud storage providers
- [ ] Add export functionality for answers
- [ ] Implement feedback mechanism for answer quality

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [LlamaIndex](https://www.llamaindex.ai/) for the fantastic framework
- [OpenAI](https://openai.com/) for the powerful language models
- [React](https://reactjs.org/) for the frontend framework
- All open-source contributors whose libraries made this project possible

---

<div align="center">
  <p>Created by <a href="https://github.com/miladnasiri">Milad Nasiri</a> with ❤️</p>
</div>
