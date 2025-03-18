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
