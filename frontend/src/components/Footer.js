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
