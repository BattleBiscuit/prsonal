import os
import re

lib_dir = '/home/dev/workspace/projects/prsonal/prsonal_app/lib'
import_stmt = "import 'package:prsonal_app/theme/app_spacing.dart';\n"

subs = {
    '4': 'space1',
    '8': 'space2',
    '12': 'space3',
    '16': 'space4',
    '20': 'space5',
    '24': 'space6',
    '32': 'space8',
    '40': 'space10',
    '48': 'space12'
}

patterns = []
for val, token in subs.items():
    patterns.append((re.compile(r'EdgeInsets\.all\(' + val + r'\)'), f'EdgeInsets.all({token})'))
    patterns.append((re.compile(r'SizedBox\(height:\s*' + val + r'\)'), f'SizedBox(height: {token})'))
    patterns.append((re.compile(r'SizedBox\(width:\s*' + val + r'\)'), f'SizedBox(width: {token})'))
    patterns.append((re.compile(r'horizontal:\s*' + val + r'(?=[,}])'), f'horizontal: {token}'))
    patterns.append((re.compile(r'vertical:\s*' + val + r'(?=[,}])'), f'vertical: {token}'))

for root, _, files in os.walk(lib_dir):
    for f in files:
        if not f.endswith('.dart'):
            continue
        path = os.path.join(root, f)
        with open(path, 'r') as file:
            content = file.read()
        
        orig_content = content
        for pattern, replacement in patterns:
            content = pattern.sub(replacement, content)
            
        if content != orig_content:
            # Check if import exists
            if 'package:prsonal_app/theme/app_spacing.dart' not in content:
                # Insert after last import
                lines = content.split('\n')
                last_import = -1
                for i, line in enumerate(lines):
                    if line.startswith('import '):
                        last_import = i
                
                if last_import != -1:
                    lines.insert(last_import + 1, "import 'package:prsonal_app/theme/app_spacing.dart';")
                else:
                    lines.insert(0, "import 'package:prsonal_app/theme/app_spacing.dart';")
                content = '\n'.join(lines)
            
            with open(path, 'w') as file:
                file.write(content)
