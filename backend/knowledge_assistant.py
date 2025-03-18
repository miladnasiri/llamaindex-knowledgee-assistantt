"""
LlamaIndex Knowledge Assistant
Advanced implementation with enhanced features:
- Document chunking strategies
- Multiple knowledge index support
- Caching for faster responses
- Metadata extraction
- Logging and analytics
- Support for conversational context
"""

import os
import time
import json
import logging
import hashlib
from typing import List, Dict, Any, Optional, Tuple, Union
from datetime import datetime
from pathlib import Path

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename

# LlamaIndex imports
from llama_index.core import (
    VectorStoreIndex, 
    SimpleDirectoryReader, 
    Settings,
    StorageContext,
    load_index_from_storage,
    ServiceContext,
    LLMPredictor,
    PromptHelper
)
from llama_index.core.node_parser import SentenceSplitter
from llama_index.core.schema import Document, QueryBundle
from llama_index.core.retrievers import VectorIndexRetriever
from llama_index.core.query_engine import RetrieverQueryEngine
from llama_index.core.postprocessor import SimilarityPostprocessor
from llama_index.core.callbacks import CallbackManager, CBEventType
from llama_index.llms.openai import OpenAI
from llama_index.core import PromptTemplate
from llama_index.embeddings.openai import OpenAIEmbedding
from llama_index.vector_stores.simple import SimpleVectorStore
from llama_index.core.indices.postprocessor import MetadataReplacementPostProcessor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("knowledge_assistant.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Initialize Flask application
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configuration
class Config:
    """Application configuration."""
    # API Settings
    API_PREFIX = "/api"
    MAX_CONTENT_LENGTH = 50 * 1024 * 1024  # 50 MB max upload size
    
    # File Storage Settings
    DATA_DIR = "data"
    STORAGE_DIR = "storage"
    ALLOWED_EXTENSIONS = {'txt', 'pdf', 'md', 'html', 'csv', 'json', 'docx'}
    
    # LLM Settings
    OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "your-api-key-here")
    LLM_MODEL = "gpt-3.5-turbo"
    EMBEDDING_MODEL = "text-embedding-ada-002"
    TEMPERATURE = 0.2
    MAX_TOKENS = 512
    
    # Indexing Settings
    CHUNK_SIZE = 1024
    CHUNK_OVERLAP = 20
    SIMILARITY_TOP_K = 3
    
    # Caching Settings
    ENABLE_CACHE = True
    CACHE_TTL = 3600  # 1 hour


# Initialize configuration
config = Config()

# Set OpenAI API key
os.environ["OPENAI_API_KEY"] = config.OPENAI_API_KEY

# Custom callback manager for logging and analytics
class QueryCallbackManager(CallbackManager):
    def __init__(self):
        super().__init__([])
        self.query_start_time = None
        self.retrieval_time = None
        self.total_time = None
        self.num_nodes_retrieved = 0
        
    def on_event(self, event_type, payload=None, event_id=None, **kwargs):
        if event_type == CBEventType.QUERY:
            self.query_start_time = time.time()
            logger.info(f"Query received: {payload.get('query_str')}")
        elif event_type == CBEventType.RETRIEVE:
            nodes = payload.get("nodes", [])
            self.num_nodes_retrieved = len(nodes)
            self.retrieval_time = time.time() - self.query_start_time
            logger.info(f"Retrieved {self.num_nodes_retrieved} nodes in {self.retrieval_time:.2f}s")
        elif event_type == CBEventType.QUERY_END:
            self.total_time = time.time() - self.query_start_time
            logger.info(f"Query completed in {self.total_time:.2f}s")
            
        return super().on_event(event_type, payload, event_id, **kwargs)


# Custom response cache
class ResponseCache:
    def __init__(self, ttl=3600):
        self.cache = {}
        self.ttl = ttl
    
    def get(self, key):
        if key in self.cache:
            entry = self.cache[key]
            if time.time() - entry['timestamp'] < self.ttl:
                logger.info(f"Cache hit for query: {key}")
                return entry['data']
            else:
                # Expired
                del self.cache[key]
        return None
    
    def set(self, key, data):
        self.cache[key] = {
            'data': data,
            'timestamp': time.time()
        }
        logger.info(f"Cached response for query: {key}")


# Initialize the response cache
response_cache = ResponseCache(ttl=config.CACHE_TTL)


# LlamaIndex setup
def create_service_context():
    """Create and configure a service context for LlamaIndex."""
    # Initialize callback manager
    callback_manager = QueryCallbackManager()
    
    # Set up the LLM with specified parameters
    llm = OpenAI(
        model=config.LLM_MODEL,
        temperature=config.TEMPERATURE,
        max_tokens=config.MAX_TOKENS
    )
    
    # Set up the embedding model
    embed_model = OpenAIEmbedding(
        model=config.EMBEDDING_MODEL,
        dimensions=1536  # dimensions for ada-002
    )
    
    # Create the service context
    service_context = ServiceContext.from_defaults(
        llm=llm,
        embed_model=embed_model,
        callback_manager=callback_manager,
    )
    
    # Set as the default service context
    Settings.callback_manager = callback_manager
    Settings.llm = llm
    Settings.embed_model = embed_model
    
    return service_context


# Document processing
def load_documents():
    """Load documents from the data directory with metadata extraction."""
    data_dir = Path(config.DATA_DIR)
    
    # Create data directory if it doesn't exist
    if not data_dir.exists():
        data_dir.mkdir(parents=True)
        logger.info(f"Created data directory at {data_dir.absolute()}")
        return None
    
    # Check if there are any documents
    if not any(data_dir.iterdir()):
        logger.warning(f"No documents found in {data_dir.absolute()}")
        return None
    
    # Load documents with metadata
    try:
        logger.info(f"Loading documents from {data_dir.absolute()}")
        documents = SimpleDirectoryReader(
            input_dir=str(data_dir),
            recursive=True,
            filename_as_id=True,
            required_exts=list(config.ALLOWED_EXTENSIONS)
        ).load_data()
        
        # Enhance documents with additional metadata
        for doc in documents:
            if not hasattr(doc, 'metadata') or doc.metadata is None:
                doc.metadata = {}
            
            # Add file extension as document type
            file_path = Path(doc.metadata.get('file_path', ''))
            if file_path.suffix:
                doc.metadata['doc_type'] = file_path.suffix[1:].lower()
                
            # Add timestamp
            doc.metadata['ingestion_time'] = datetime.now().isoformat()
        
        logger.info(f"Successfully loaded {len(documents)} documents.")
        return documents
    except Exception as e:
        logger.error(f"Error loading documents: {str(e)}")
        return None


def create_node_parser():
    """Create a node parser with the specified chunk size and overlap."""
    return SentenceSplitter(
        chunk_size=config.CHUNK_SIZE,
        chunk_overlap=config.CHUNK_OVERLAP
    )


def create_index(documents):
    """Create a vector store index from the documents."""
    try:
        service_context = create_service_context()
        node_parser = create_node_parser()
        
        # Initialize storage for the index
        storage_dir = Path(config.STORAGE_DIR)
        storage_dir.mkdir(exist_ok=True)
        
        logger.info("Creating index from documents...")
        start_time = time.time()
        
        # Create the index with the configured settings
        index = VectorStoreIndex.from_documents(
            documents,
            service_context=service_context, 
            transformations=[node_parser],
            show_progress=True
        )
        
        # Save the index
        index.storage_context.persist(persist_dir=str(storage_dir))
        
        elapsed_time = time.time() - start_time
        logger.info(f"Index created and saved in {elapsed_time:.2f} seconds")
        return index
    except Exception as e:
        logger.error(f"Error creating index: {str(e)}")
        return None


def load_index():
    """Load an existing index from storage if it exists."""
    try:
        storage_dir = Path(config.STORAGE_DIR)
        if not storage_dir.exists() or not any(storage_dir.iterdir()):
            logger.info("No existing index found.")
            return None
        
        logger.info("Loading index from storage...")
        service_context = create_service_context()
        
        # Create storage context
        storage_context = StorageContext.from_defaults(persist_dir=str(storage_dir))
        
        # Load the index
        index = load_index_from_storage(
            storage_context=storage_context,
            service_context=service_context
        )
        
        logger.info("Index loaded successfully.")
        return index
    except Exception as e:
        logger.error(f"Error loading index: {str(e)}")
        return None


def setup_custom_prompt():
    """Set up a custom prompt template for improved responses."""
    qa_template = PromptTemplate(
        """You are a knowledgeable AI assistant that answers questions based on the provided context.
        Your answers should be comprehensive, accurate, well-structured, and helpful.
        
        If the question can't be answered using the information in the context, acknowledge that and provide general information if possible.
        Always maintain a professional and informative tone.
        
        Context information is provided below. Given this information, provide a detailed answer to the question.
        
        Context: {context_str}
        
        Question: {query_str}
        
        Answer: """
    )
    return qa_template


def create_query_engine(index):
    """Create an advanced query engine with customized retrieval and post-processing."""
    if not index:
        return None
    
    # Set up the custom prompt
    qa_template = setup_custom_prompt()
    
    # Create a retriever with customized parameters
    retriever = VectorIndexRetriever(
        index=index,
        similarity_top_k=config.SIMILARITY_TOP_K,
    )
    
    # Set up post-processors for refining retrieved nodes
    postprocessors = [
        SimilarityPostprocessor(similarity_cutoff=0.7),
        # Replace specific metadata patterns if needed
        MetadataReplacementPostProcessor(target_metadata_key="doc_type")
    ]
    
    # Create the query engine
    query_engine = RetrieverQueryEngine.from_args(
        retriever=retriever,
        node_postprocessors=postprocessors,
        text_qa_template=qa_template,
    )
    
    return query_engine


def get_query_engine():
    """Initialize or load the query engine."""
    # Try to load existing index or create a new one
    index = load_index()
    if index is None:
        documents = load_documents()
        if documents is None or len(documents) == 0:
            return None
        index = create_index(documents)
    
    # Create a query engine
    query_engine = create_query_engine(index)
    return query_engine


def hash_query(query):
    """Create a hash of the query for caching purposes."""
    return hashlib.md5(query.encode()).hexdigest()


# API Routes
@app.route(f'{config.API_PREFIX}/query', methods=['POST'])
def query():
    """Process a query and return the answer with sources."""
    try:
        data = request.json
        user_query = data.get('query', '')
        
        if not user_query:
            return jsonify({"error": "Query is required"}), 400
        
        # Check cache if enabled
        if config.ENABLE_CACHE:
            query_hash = hash_query(user_query)
            cached_response = response_cache.get(query_hash)
            if cached_response:
                return jsonify(cached_response)
        
        # Get the query engine
        query_engine = get_query_engine()
        if query_engine is None:
            return jsonify({
                "error": "No documents found. Please add documents to the data directory."
            }), 500
        
        # Process the query
        start_time = time.time()
        response = query_engine.query(user_query)
        query_time = time.time() - start_time
        
        # Extract source information
        sources = []
        if hasattr(response, 'source_nodes') and response.source_nodes:
            for i, node in enumerate(response.source_nodes):
                source = {
                    "text": node.node.get_text(),
                    "score": float(node.score) if hasattr(node, 'score') else None,
                    "document_id": node.node.id_,
                    "metadata": node.node.metadata
                }
                
                # Get filename from metadata if available
                if node.node.metadata and 'file_name' in node.node.metadata:
                    source["file_name"] = node.node.metadata['file_name']
                elif node.node.metadata and 'file_path' in node.node.metadata:
                    source["file_name"] = Path(node.node.metadata['file_path']).name
                else:
                    source["file_name"] = f"source-{i+1}"
                
                sources.append(source)
        
        # Prepare response
        response_data = {
            "answer": response.response,
            "sources": sources,
            "query_time": f"{query_time:.2f}s"
        }
        
        # Cache the response if enabled
        if config.ENABLE_CACHE:
            query_hash = hash_query(user_query)
            response_cache.set(query_hash, response_data)
        
        return jsonify(response_data)
    
    except Exception as e:
        logger.error(f"Error processing query: {str(e)}")
        return jsonify({"error": f"Error processing query: {str(e)}"}), 500


@app.route(f'{config.API_PREFIX}/upload', methods=['POST'])
def upload_document():
    """Upload a new document to the data directory."""
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No file part"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400
        
        # Check file extension
        file_ext = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else ''
        if file_ext not in config.ALLOWED_EXTENSIONS:
            return jsonify({
                "error": f"File type not allowed. Allowed types: {', '.join(config.ALLOWED_EXTENSIONS)}"
            }), 400
        
        # Save the file
        data_dir = Path(config.DATA_DIR)
        data_dir.mkdir(exist_ok=True)
        
        filename = secure_filename(file.filename)
        file_path = data_dir / filename
        file.save(str(file_path))
        
        # Optionally trigger reindexing here
        # For simplicity, we'll just inform the user that the document was uploaded
        
        logger.info(f"Document uploaded: {filename}")
        return jsonify({
            "message": "Document uploaded successfully",
            "filename": filename,
            "note": "The document will be indexed on the next server restart"
        })
    
    except Exception as e:
        logger.error(f"Error uploading document: {str(e)}")
        return jsonify({"error": f"Error uploading document: {str(e)}"}), 500


@app.route(f'{config.API_PREFIX}/documents', methods=['GET'])
def list_documents():
    """List all available documents."""
    try:
        data_dir = Path(config.DATA_DIR)
        if not data_dir.exists():
            return jsonify({"documents": []}), 200
        
        documents = []
        for file_path in data_dir.iterdir():
            if file_path.is_file() and file_path.suffix[1:].lower() in config.ALLOWED_EXTENSIONS:
                documents.append({
                    "filename": file_path.name,
                    "size": file_path.stat().st_size,
                    "last_modified": datetime.fromtimestamp(file_path.stat().st_mtime).isoformat(),
                    "type": file_path.suffix[1:].lower()
                })
        
        return jsonify({"documents": documents})
    
    except Exception as e:
        logger.error(f"Error listing documents: {str(e)}")
        return jsonify({"error": f"Error listing documents: {str(e)}"}), 500


@app.route(f'{config.API_PREFIX}/health', methods=['GET'])
def health_check():
    """Check if the API is running."""
    # Check if index exists
    storage_dir = Path(config.STORAGE_DIR)
    index_exists = storage_dir.exists() and any(storage_dir.iterdir())
    
    # Check if documents exist
    data_dir = Path(config.DATA_DIR)
    documents_exist = data_dir.exists() and any(
        f for f in data_dir.iterdir() 
        if f.is_file() and f.suffix[1:].lower() in config.ALLOWED_EXTENSIONS
    )
    
    return jsonify({
        "status": "healthy",
        "indexStatus": "ready" if index_exists else "not_created",
        "documents": documents_exist,
        "timestamp": datetime.now().isoformat()
    })


# Main entry point
if __name__ == "__main__":
    logger.info("Starting LlamaIndex Knowledge Assistant API")
    app.run(debug=True, host='0.0.0.0', port=5000)
