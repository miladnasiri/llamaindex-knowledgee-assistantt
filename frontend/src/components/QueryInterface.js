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
