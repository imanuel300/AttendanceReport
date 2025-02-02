import os
import csv
from datetime import datetime
import pathlib

def get_documents_path():
    return str(pathlib.Path.home() / "Documents" / "attendance_log.csv")

def initialize_csv():
    file_path = get_documents_path()
    if not os.path.exists(file_path):
        with open(file_path, 'w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(['תאריך', 'שעה', 'סוג פעולה'])

def log_action(action_type):
    file_path = get_documents_path()
    current_time = datetime.now()
    
    with open(file_path, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow([
            current_time.strftime('%Y-%m-%d'),
            current_time.strftime('%H:%M:%S'),
            action_type
        ])

def edit_last_record():
    file_path = get_documents_path()
    records = []
    
    with open(file_path, 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        records = list(reader)
    
    if len(records) > 1:  # יש לפחות רשומה אחת מלבד הכותרת
        print(f"הרשומה האחרונה: {records[-1]}")
        new_time = input("הכנס שעה חדשה (בפורמט HH:MM:SS): ")
        try:
            datetime.strptime(new_time, '%H:%M:%S')
            records[-1][1] = new_time
            
            with open(file_path, 'w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerows(records)
            print("העדכון בוצע בהצלחה!")
        except ValueError:
            print("פורמט שעה לא תקין!")
    else:
        print("אין רשומות לעריכה!")

def main():
    # קידוד נכון לעברית בחלון הקונסול
    if os.name == 'nt':  # Windows
        os.system('chcp 65001')
        os.system('cls')
    
    initialize_csv()
    
    while True:
        print("\nמערכת דיווח נוכחות:")
        print("1. כניסה לעבודה")
        print("2. יציאה מהעבודה")
        print("3. תיקון דוח אחרון")
        print("4. יציאה מהתוכנה")
        
        choice = input("בחר אפשרות (1-4): ")
        
        if choice == '1':
            log_action("כניסה")
            print("כניסה נרשמה בהצלחה!")
        elif choice == '2':
            log_action("יציאה")
            print("יציאה נרשמה בהצלחה!")
        elif choice == '3':
            edit_last_record()
        elif choice == '4':
            print("להתראות!")
            break
        else:
            print("אפשרות לא תקינה!")

if __name__ == "__main__":
    main() 