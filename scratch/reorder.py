import re

def parse_dart_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    
    pre_class = []
    class_def = ""
    post_class = []
    
    in_class = False
    class_start_idx = -1
    
    for i, line in enumerate(lines):
        if re.match(r'^class \w+(?: \w+)* {', line):
            in_class = True
            class_def = line
            class_start_idx = i
            pre_class = lines[:i]
            break

    if not in_class:
        return None

    class_body_lines = []
    bracket_level = 1
    
    class_end_idx = -1
    for i in range(class_start_idx + 1, len(lines)):
        line = lines[i]
        bracket_level += line.count('{') - line.count('}')
        if bracket_level == 0:
            class_end_idx = i
            break
        class_body_lines.append(line)
        
    post_class = lines[class_end_idx:]
    
    items = []
    current_item_lines = []
    bracket_level = 1
    
    for line in class_body_lines:
        current_item_lines.append(line)
        bracket_level += line.count('{') - line.count('}')
        if bracket_level == 1:
            if line.strip().endswith(';') or line.strip().endswith('}'):
                items.append("\n".join(current_item_lines))
                current_item_lines = []
            elif line.strip() == "":
                if "".join(current_item_lines).strip() == "":
                    current_item_lines = []

    if "".join(current_item_lines).strip() != "":
        items.append("\n".join(current_item_lines))
        
    fields_and_private = []
    public_methods = []
    
    for item in items:
        # Robust regex for method signatures like: Future<Map<String, dynamic>?> methodName(
        match = re.search(r'^\s*Future.*?\s+([a-zA-Z0-9_]+)\s*\(', item, re.MULTILINE)
        if match:
            method_name = match.group(1)
            if method_name.startswith('_'):
                fields_and_private.append(item)
            else:
                public_methods.append({
                    'name': method_name,
                    'content': item
                })
        else:
            fields_and_private.append(item)
            
    return pre_class, class_def, fields_and_private, public_methods, post_class

def get_group_from_url(method_content, default_group="Other"):
    match = re.search(r"['\"]([^/]+)/([^/]+Api)(?:/|['\"])", method_content)
    if match:
        return match.group(2)
    return default_group

def process_api_manager():
    res = parse_dart_file('lib/data/api/api_manager.dart')
    if not res:
        print("Failed to parse api_manager")
        return
        
    pre, cdef, priv, pub, post = res
    
    grouped = {}
    for m in pub:
        group = get_group_from_url(m['content'])
        if group not in grouped:
            grouped[group] = []
        grouped[group].append(m)
        
    with open('lib/data/api/api_manager.dart', 'w', encoding='utf-8') as f:
        f.write("\n".join(pre) + "\n")
        f.write(cdef + "\n")
        for p in priv:
            f.write(p + "\n\n")
            
        groups_order = [
            "AccountApi", "AppointmentApi", "BookingApi", "ClinicApi",
            "DepartmentApi", "DoctorApi", "HistoryApi", "NotificationApi",
            "PatientApi", "ProfileApi", "ScheduleApi", "Other"
        ]
        
        for g in groups_order:
            if g in grouped and grouped[g]:
                f.write(f"  // ==========================================\n")
                f.write(f"  // {g}\n")
                f.write(f"  // ==========================================\n\n")
                for m in grouped[g]:
                    f.write(m['content'] + "\n\n")
                    
        f.write("\n".join(post) + "\n")
    print("Processed api_manager.dart successfully!")

def process_repository():
    res = parse_dart_file('lib/data/repository/repository.dart')
    if not res:
        print("Failed to parse repository")
        return
        
    pre, cdef, priv, pub, post = res
    
    grouped = {}
    for m in pub:
        content = m['content']
        match = re.search(r'apiManager\.([a-zA-Z0-9_]+)', content)
        group = "Other"
        if match:
            api_method_name = match.group(1)
            with open('lib/data/api/api_manager.dart', 'r', encoding='utf-8') as f:
                api_content = f.read()
            api_match = re.search(r'^\s*Future.*?\s+' + api_method_name + r'\s*\(', api_content, re.MULTILINE)
            if api_match:
                # Find the URL in that method block (roughly next 1000 chars)
                api_block = api_content[api_match.start():api_match.start()+1000]
                group = get_group_from_url(api_block)
        
        if group not in grouped:
            grouped[group] = []
        grouped[group].append(m)
        
    with open('lib/data/repository/repository.dart', 'w', encoding='utf-8') as f:
        f.write("\n".join(pre) + "\n")
        f.write(cdef + "\n")
        for p in priv:
            f.write(p + "\n\n")
            
        groups_order = [
            "AccountApi", "AppointmentApi", "BookingApi", "ClinicApi",
            "DepartmentApi", "DoctorApi", "HistoryApi", "NotificationApi",
            "PatientApi", "ProfileApi", "ScheduleApi", "Other"
        ]
        
        for g in groups_order:
            if g in grouped and grouped[g]:
                f.write(f"  // ==========================================\n")
                f.write(f"  // {g}\n")
                f.write(f"  // ==========================================\n\n")
                for m in grouped[g]:
                    f.write(m['content'] + "\n\n")
                    
        f.write("\n".join(post) + "\n")
    print("Processed repository.dart successfully!")

if __name__ == '__main__':
    process_api_manager()
    process_repository()
