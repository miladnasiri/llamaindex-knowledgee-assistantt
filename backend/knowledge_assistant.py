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
