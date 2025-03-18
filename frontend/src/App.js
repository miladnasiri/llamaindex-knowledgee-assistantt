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
