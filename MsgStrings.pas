// Модуль содержащий все сообщения

unit MsgStrings;

interface



resourcestring
 // Form1
 rsCopyng='Копирование';
 rsMirror='Зеркалирование';
 rsSync='Синхронизация';
 rsArcZip='Архивация Zip';
 rsArcRar='Архивация Rar';
 rsEnterLogFile='Введите имя log файла';
 rsIsRunning='Выполняется';
 rsIsWaiting='На выполнение';
 rsManual='Вручную';
 rsAtStart='При запуске';
 rsDisabled='Отключена';
 rsEnabled='Включена';
 rsTaskNeverRun='Не запускалась';
 rsOk='Ок';
 rsYes='Да';
 rsNo='Нет';
 rsTaskError='Ошибка';
 rsTaskEndError='Warn';    // Выполнено с ошибками
 rsAlertRunMes='Программа запущена';
 rsAlertRunSubj='Autosave alert';
 rsQuestDeleteTask='Удалить задание %s?';
 // FormTask
 rsEnterSource='Укажите источник';
 rsEnterDest='Укажите приемник';
 rsDirNotExsistCreate='Каталог %s не существует. Создать?';
 rsDirCreated='Каталог создан';
 rsErrCreateDir='Ошибка создания каталога';
 rsSelectAction='Выберите действие';
 rsNoRar='Rar.exe не найден, архивация невозможна';
 rsNoArcName='Укажите название архива';
 // TaskUnit
 rsLogRunTask='Запуск задачи';
 rsAlert='Уведомление о выполненном задании';
 rsLogExtProgRun='Запуск внешней программы';
 rsLogExtProgEnd='Внешняя программа выполнена. Код выхода %s';
 rsLogExtProgErr='[Ошибка] Запуск внешней программы %s невозможен';
 rsLogExtProgErrEx='[Ошибка] Запуск внешней программы %s вызвал исключение %s';
 rsLogCopy='Копирование %s в %s';
 rsLogSync='Синхронизация %s в %s';
 rsLogMirror='Зеркалирование %s в %s';
 rsLogArcRar='Архивация rar %s в %s';
 rsLogArcZip='Архивация zip %s в %s';
 rsLogTaskEnd='Задача завершена';
 rsLogTaskEndOk='Задача %s успешно завершена';
 rsLogTaskEndErr='Задача %s завершена с ошибкой';
 rsLogTaskError='[Ошибка] Задача %s не выполнена';
 rsAlertSubjOk='AutoSave Ok Alert';
 rsAlertSubjErr='AutoSave ERROR alert';
 rsAlertSubjWarn='AutoSave WARNING alert';
 rsLogDirNotFound='[Ошибка] Каталог %s недоступен';
 rsLogDirCreated='[Предупреждение] Каталог %s был создан';
 rsLogDirCreateErr='[Ошибка] Каталог %s не удалось создать. %s';
 rsLogNoZipDll='[Ошибка] Zip не поддерживается';
 rsLogArcCreated='Создан архив %s';
 rsLogArcErr='[Ошибка] Архиватор вернул фатальную ошибку (код возврата %s). Имя архива: %s';
 rsLogArcWarn='[Предупреждение] Архиватор вернул предупреждение. Имя архива: %s';

 rsCopyPerfix='Копия';
 rsLogRarNotFound='[Ошибка] Rar.exe не найден';
 rsLogDelFile='Удален файл %s';
 rsLogDelFileErr='[Ошибка] Не удалось удалить файл %s. %s';
 rsLogFileCopied='Файл скопирован: %s';
 rsLogfileCopiedErr='[Ошибка] Неудалось скопировать файл %s. %s';
 rsLogDelDir='Удалена директория %s';
 rsLogDelDirErr='[Ошибка] Не удалось удалить директорию %s. %s';
 rsTaskIsRunning='Выполняется задача %s';
 rsAlertTestOk='Письмо успешно отправлено';
 rsAlertTestErr='Письмо не удалось отправить: %s';
 rsLogFileDateErr='[Предупреждение] Не удалось получить дату изменения файла %s';
 rsLogFileDateErrEx='[Предупреждение] Не удалось получить дату изменения файлов %s, %s. %s';
 rsLog7zipNotFound='[Ошибка] 7z.exe не найден';
 rsLogArcErrCmd='[Ошибка] Архиватор вернул ошибку. Неверная командная строка. Имя архива: %s';
 rsLogArcErrMemory='[Ошибка] Архиватор вернул ошибку. Недостаточно памяти для операции. Имя архива: %s';
 rsLogArcWarnUserStop='[Предупреждение] Архиватор вернул предупреждение. Процесс прерван пользователем. Имя архива: %s';
 rsLogArc7Zip='Архивация 7zip %s в %s';
 rsNo7zip='7za.exe не найден, архивация невозможна';
 rsArc7Zip='Архивация 7zip';
implementation

end.
