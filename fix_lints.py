import glob
import re

files = glob.glob('lib/**/*.dart', recursive=True)
for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
    if 'print(' in new_content and 'api_service.dart' in f:
        new_content = new_content.replace('print(', '// debug: print(')
        
    with open(f, 'w') as file:
        file.write(new_content)
