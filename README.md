# fgsiz

Fgsiz product catalog

Здесь предствален, проэкт каталога для скачивания apk перейдите по ссылке ниже 
https://disk.yandex.ru/d/37PByHsiLjotnA
Для создания ios версии необходимо что то на macOS и данная программа https://developer.apple.com/xcode/, в нее нужно будет установить плагин flutter ввести копанды flutter pub get и flutter upgrade dependeces,
в теории еслит манифест ios не сильно отличается от android то сразу проэкт можно будет собрать и собрать в релизный установщик


По дизайну я хз делал на свой вкус, я подумывал сделать разделение между лепесток спиро и переходом в кталог но в спиро и лепесток наверное тоже нужен какой то свой дизайн тогда......

Сразу напишу систему что бы если что легко добавлять продукты в проекте есть каталог assets в котором храняться все ресурсы
product.json описывает все продукты что отображаются вот пример элемента
  {
    "name": "«СПИРО–113»",
    "imageUrls": ["Kakotkin_com_27102022_0140_DxO.png", "Kakotkin_com_27102022_0141_DxO.png", "Kakotkin_com_27102022_0022_DxO.png"],
    "description": "spir113",
    "designations": [
      "FFP3",
      "NR",
      "D",
      "До 50 ПДК",
      "С клапаном для дыхания",
      "СПИРО"
    ],
    "standard": "ТУ 9398-011-08625805-2011\nГОСТ 12.4.294-2015"
  },

  В первой строке описано отображаемое имя во второй ссылка на фотографию (они храняться в каталоге images), также фотографии могут быть любые я предусмотрел их разрешения и сделал проверку на соотношения сторон (жнлательно не в 4к фотки а то сами понимаете скорость прогрузки 4к изображения..... )
  Снизу идет описания продукта, что будет отображаться на странице с ним (описания храняться в txt файлах в папке description)
  Дальше идут теги продукта, то на чем основан поиск, т.к программа в начале создает их уникальный список то желательно писать их оддинаковыми(в ковычках через звпятую), ну и добавлять что бы подчеркнуть уникальность ну понятно я думаю
  Последняя строка отвечает за то что будет отображаться под названием т.к обычно это стандарт я ее так и назвал но в паринцепе текст не имеет значения.
  (Программа чувствительная к пец имволам такие как \n в конце строк если вы не хотите через нее казать новую строку и т.д то проверяйте что их нет)
