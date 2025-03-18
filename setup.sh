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
