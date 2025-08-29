from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
supabase = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

print('Testing simple text search...')
result = supabase.table('documents').select('content, metadata').ilike('content', '%Punjab%').limit(3).execute()
print(f'Found {len(result.data)} documents with Punjab')
for doc in result.data:
    print(f'Document: {doc.get("content", "")[:100]}...')
    print('---')

print('\nTesting all documents count...')
all_docs = supabase.table('documents').select('id').execute()
print(f'Total documents: {len(all_docs.data)}')

print('\nTesting vector search function...')
try:
    import google.generativeai as genai
    genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
    
    # Generate embedding for test query
    result = genai.embed_content(model='models/text-embedding-004', content='Punjab agriculture crops')
    embedding = result['embedding']
    print(f'Generated embedding with {len(embedding)} dimensions')
    
    # Test the match_documents function
    search_result = supabase.rpc('match_documents', {
        'query_embedding': embedding,
        'match_threshold': 0.1,  # Lower threshold for testing
        'match_count': 5
    }).execute()
    
    print(f'Vector search found {len(search_result.data)} results')
    for i, doc in enumerate(search_result.data):
        content = doc.get('content', '')[:100]
        similarity = doc.get('similarity', 'N/A')
        print(f'Result {i+1}: {content}... (similarity: {similarity})')
        
except Exception as e:
    print(f'Vector search error: {e}')
