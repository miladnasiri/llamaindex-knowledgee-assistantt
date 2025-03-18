import React, { useState } from 'react';

const QueryInterface = () => {
  const [query, setQuery] = useState('');
  const [answer, setAnswer] = useState('');
  const [sources, setSources] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [showSources, setShowSources] = useState(false);
  
  // Function to handle form submission
  const handleSubmit = async () => {
    if (!query.trim()) return;
    
    setIsLoading(true);
    
    try {
      // Replace this with your actual API call
      // Example:
      // const response = await fetch('/api/query', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify({ query })
      // });
      // const data = await response.json();
      
      // For demo purposes, we'll simulate a response after 1 second
      setTimeout(() => {
        // Mock response data
        const mockAnswer = "LlamaIndex is a data framework for LLM applications to ingest, structure, and access private or domain-specific data. It provides data connectors to ingest your existing data sources and APIs. It also provides ways to structure your data for different use cases, as well as ways to update the data. Finally, it allows you to query your data using natural language and build applications.";
        
        const mockSources = [
          {
            file_name: "sample.txt",
            text: "LlamaIndex is a data framework for LLM applications to ingest, structure, and access private or domain-specific data. It was created by Jerry Liu in late 2022."
          },
          {
            file_name: "documentation.pdf",
            text: "LlamaIndex provides data connectors to ingest your existing data sources and APIs. It also provides ways to structure your data for different use cases, as well as ways to update the data."
          }
        ];
        
        setAnswer(mockAnswer);
        setSources(mockSources);
        setIsLoading(false);
      }, 1000);
      
    } catch (error) {
      console.error('Error fetching answer:', error);
      setIsLoading(false);
    }
  };
  
  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      {/* Header */}
      <header className="bg-gradient-to-r from-blue-700 to-indigo-800 text-white p-6 shadow-lg">
        <div className="max-w-5xl mx-auto">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold">LlamaIndex Knowledge Assistant</h1>
              <p className="text-blue-100 mt-2">Intelligent document search & insights powered by AI</p>
            </div>
            <div className="hidden md:block">
              <img src="/api/placeholder/80/80" alt="LlamaIndex Logo" className="h-12 w-12" />
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 max-w-5xl w-full mx-auto p-4 md:p-6 lg:p-8">
        {/* Search Section */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Ask Your Documents</h2>
          <form onSubmit={(e) => {
            e.preventDefault();
            handleSubmit();
          }} className="flex flex-col md:flex-row gap-3">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="What is LlamaIndex used for?"
              className="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
            />
            <button 
              type="submit"
              disabled={isLoading}
              className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-6 rounded-lg transition duration-200 ease-in-out disabled:bg-blue-400"
            >
              {isLoading ? 'Processing...' : 'Ask'}
            </button>
          </form>
          
          <div className="mt-4 text-gray-600 text-sm">
            <div className="flex items-center">
              <span className="mr-1 text-blue-600">💡</span>
              <span>Try asking: "What are the key features of LlamaIndex?" or "How do I get started with LlamaIndex?"</span>
            </div>
          </div>
        </div>

        {/* Results Section */}
        {answer && (
          <div className="bg-white rounded-xl shadow-md overflow-hidden mb-8">
            <div className="border-b border-gray-100">
              <div className="flex justify-between items-center p-6">
                <h2 className="text-xl font-semibold text-gray-800">Answer</h2>
                <div className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">AI Generated</div>
              </div>
            </div>
            
            <div className="p-6">
              <div className="prose max-w-none">
                <p>{answer}</p>
              </div>
              
              {sources && sources.length > 0 && (
                <div className="mt-6 pt-6 border-t border-gray-100">
                  <button 
                    onClick={() => setShowSources(!showSources)}
                    className="flex items-center text-sm font-medium text-blue-600 hover:text-blue-800"
                  >
                    <span className="mr-2">{showSources ? 'Hide' : 'View'} Sources ({sources.length})</span>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      {showSources ? 
                        <path d="M18 15l-6-6-6 6"/> : 
                        <path d="M6 9l6 6 6-6"/>
                      }
                    </svg>
                  </button>
                  
                  {showSources && (
                    <div className="mt-4 space-y-4">
                      {sources.map((source, index) => (
                        <div key={index} className="bg-gray-50 rounded-lg p-4">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center">
                              <span className="inline-flex items-center justify-center h-6 w-6 rounded-full bg-blue-100 text-blue-800 text-xs font-medium mr-2">
                                {index + 1}
                              </span>
                              <span className="text-sm font-medium">{source.file_name}</span>
                            </div>
                            <span className="text-xs text-gray-500">Relevance: High</span>
                          </div>
                          <div className="text-sm text-gray-700 border-l-2 border-gray-200 pl-3">
                            {source.text}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}
        
        {/* Features Section */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
                <polyline points="2 17 12 22 22 17"></polyline>
                <polyline points="2 12 12 17 22 12"></polyline>
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-800 mb-2">Data Ingestion</h3>
            <p className="text-gray-600 text-sm">Connect to multiple data sources including PDFs, text, and more.</p>
          </div>
          
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="w-10 h-10 rounded-lg bg-indigo-100 flex items-center justify-center mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-indigo-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="3"></circle>
                <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-800 mb-2">Natural Language Queries</h3>
            <p className="text-gray-600 text-sm">Ask questions in plain English and get accurate answers from your data.</p>
          </div>
          
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                <line x1="12" y1="22.08" x2="12" y2="12"></line>
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-800 mb-2">Source Attribution</h3>
            <p className="text-gray-600 text-sm">See which documents and sources were used to generate each answer.</p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 py-6">
        <div className="max-w-5xl mx-auto px-4 text-center">
          <p className="text-gray-600 text-sm">
            Built with <a href="https://llamaindex.ai" className="text-blue-600 hover:underline">LlamaIndex</a> and React
          </p>
          <p className="text-gray-500 text-xs mt-2">
            <a href="https://github.com/miladnasiri/llamaindex-knowledgee-assistantt" className="hover:underline">
              GitHub Repository
            </a>
          </p>
        </div>
      </footer>
    </div>
  );
};

export default QueryInterface;
