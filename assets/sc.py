def clean_description_from_txt(file_path):
    """
    Очищает поля "description" в текстовом файле, удаляя все символы между "description" и "designations".

    Args:
        file_path (str): Путь к текстовому файлу.
    """

    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()

    # Находим позиции "description" и "designations"
    description_start = content.find('"description":')
    designations_start = content.find('"designations":')

    # Если оба поля найдены, удаляем все между ними
    if description_start != -1 and designations_start != -1:
        cleaned_content = content[:description_start] + content[designations_start:]
    else:
        cleaned_content = content

    # Записываем очищенный текст в файл
    with open(file_path, "w", encoding="utf-8") as file:
        file.write(cleaned_content)

    print("Описание очищено!")

# Пример использования
file_path = "prod2.txt"  # Замените на путь к вашему файлу
clean_description_from_txt(file_path)