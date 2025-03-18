## Technologies Used

### Backend
- **Flask**: Lightweight web framework for Python used to create the REST API
- **LlamaIndex**: Data framework for connecting LLMs with external data
- **OpenAI API**: Powers the language model for generating responses
- **Vector Embeddings**: Stores document semantics for efficient retrieval
- **Flask-CORS**: Handles Cross-Origin Resource Sharing for API requests

### Frontend
- **React**: JavaScript library for building the user interface
- **React Router**: Handles page navigation
- **Axios**: Promise-based HTTP client for API requests
- **ReactMarkdown**: Renders markdown content in the UI

### Data Processing
- **Sentence Splitter**: For optimal document chunking
- **Custom Prompt Templates**: Improves response quality
- **Response Caching**: Speeds up repeated queries
- **Metadata Extraction**: Enhances document understanding

### Not Used
- **Jupyter Notebooks**: The application is a standalone web service, not a notebook-based implementation
- **nest_asyncio**: Not required as our application doesn't involve nested event loops
- **Next.js**: We use React directly without the Next.js framework

The project follows a modern client-server architecture with a clear separation between the frontend UI and backend API. All document processing, embedding generation, and interaction with the language model happens on the backend, while the frontend provides an intuitive interface for users to interact with their documents.
