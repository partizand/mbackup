// Модуль содержащий все сообщения

unit msgstrings;

interface



resourcestring
 // Form1
 rsCopyng='Copying';
 rsMirror='Mirroring';
 rsSync='Synchronization';
 rsArcZip='Archiving Zip';
 rsArcRar='Archiving Rar';
 rsEnterLogFile='Enter log file name';
 rsIsRunning='Running';
 rsIsWaiting='Waiting';
 rsManual='Manual';
 rsAtStart='At stratup';
 rsDisabled='Disabled';
 rsEnabled='Enabled';
 rsTaskNeverRun='Never';
 rsOk='Ok';
 rsYes='Yes';
 rsNo='No';
 rsTaskError='Error';
 rsTaskEndError='Warning';    // Выполнено с ошибками
 rsAlertRunMes='Program started';
 rsAlertRunSubj='mBackup alert';
 rsQuestDeleteTask='Delete task %s?';
 // FormTask
 rsEnterSource='Enter source';
 rsEnterDest='Enter destination';
 rsDirNotExsistCreate='Directory %s not exist. Create?';
 rsDirCreated='Directory created';
 rsErrCreateDir='Error creating directory';
 rsSelectAction='Select action';
 rsNoRar='Rar.exe not found, archiving is not possible';
 rsNoArcName='Enter arh name';
 // TaskUnit
 rsLogRunTask='Task started';
 rsAlert='Task alert';
 rsLogExtProgRun='Start external program';
 rsLogExtProgEnd='External program complete. Exit code %s';
 rsLogExtProgErr='[Error] Cannot start external program %s';
 rsLogExtProgErrEx='[Error] External program %s throw exception %s';
 rsLogCopy='Copying %s to %s';
 rsLogSync='Sync %s to %s';
 rsLogMirror='Mirroring %s to %s';
 rsLogArcRar='Archiving Rar %s to %s';
 rsLogArcZip='Archiving zip %s to %s';
 rsLogTaskEnd='Task ended';
 rsLogTaskEndOk='Task %s sucsessfuly ended';
 rsLogTaskEndErr='Task %s ended with warnings';
 rsLogTaskError='[Error] Task %s failed to start';
 //rsAlertSubjOk='mBackup Ok Alert';
// rsAlertSubjErr='mBackup ERROR alert';
// rsAlertSubjWarn='mBackup WARNING alert';
 rsLogDirNotFound='[Error] Cannot find directory %s';
 rsLogDirCreated='[Warning] Directory was created %s';
 rsLogDirCreateErr='[Error] Cannot create directory %s. %s';
// rsLogNoZipDll='[Error] Zip не поддерживается';
 rsLogArcCreated='Archive was created %s';
 rsLogArcErr='[Error] Archiver return fatal error (Exit code %s). Archive name: %s';
 rsLogArcWarn='[Warning] Archiver return warning. Archive name: %s';
 rsCopyPerfix='Copy of ';
 rsLogRarNotFound='[Error] Rar.exe is not found';
 rsLogDelFile='File deleted %s';
 rsLogDelFileErr='[Error] Cannot delete file %s. %s';
 rsLogFileCopied='File copied: %s';
 rsLogfileCopiedErr='[Error] Cannot copy file %s. %s';
 rsLogDelDir='Directory deleted %s';
 rsLogDelDirErr='[Error] Cannot delete directory %s. %s';
 rsTaskIsRunning='Task is running %s';
 rsAlertTestOk='Mail sucsessfuly sended';
 rsAlertTestErr='Cannot send mail: %s';
 rsLogFileDateErr='[Warning] Cannot get file date %s';
 rsLogFileDateErrEx='[Warning] Cannot get files date %s, %s. %s';
 rsLog7zipNotFound='[Error] 7z.exe is not found';
 rsLogArcErrCmd='[Error] Archiver return error. Invalid arguments. Archive name: %s';
 rsLogArcErrMemory='[Error] Archiver return error. Not enouth memory. Archive name: %s';
 rsLogArcWarnUserStop='[Warning] Archiver return warning. Process terminated by user. Archive name: %s';
 rsLogArc7Zip='Archiving 7zip %s to %s';
 rsNo7zip='7za.exe not found, cannot start arh';
 rsArc7Zip='Archiving 7zip';
 rsArcOldCheckName='Store arhs';
 rsZerkOldCheckName='Keep deleted files';
 rsAlertAuthErr='Cannot send mail. Did not authenticate';
 rsExclude='Exclude';
 rsOnlyThese='Only these';
 rsNone='None';
 rsOnlyError='Only when an error';
 rsAlways='Always';
implementation

end.
