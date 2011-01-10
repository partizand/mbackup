unit SendMailUnit;

{$mode objfpc}{$H+}

{
Отправка почты

}

interface

uses
  Classes, SysUtils,lNet, lSMTP, lMimeWrapper;


// класс для отправки почты
type
  TSendMail = class
   private
    FSMTP: TLSMTPClient; // this is THE smtp connection
//    FSSL: TLSSLSession;
    FConn: Boolean; // Соединено с сервером
    FErr:Boolean; // Ошибка при соединении

//    function GetAnswer(const s: string; const MaskInput: Boolean = False): string;
    { these events are used to see what happens on the SMTP connection. They are used via "CallAction".
      OnReceive will get fired whenever new data is received from the SMTP server.
      OnConnect will get fired when connecting to server ended with success.
      OnDisconnect will get fired when the other side closed connection gracefully.
      OnError will get called when any kind of net error occurs on the connection. }
    procedure OnReceive(aSocket: TLSocket);
    procedure OnConnect(aSocket: TLSocket);
    procedure OnDisconnect(aSocket: TLSocket);
    procedure OnError(const msg: string; aSocket: TLSocket);
    { This event is used to monitor TLS handshake. If SSL or TLS is used
      we will know if the handshake went ok if this event is fired on the seesion }
//    procedure OnSSLConnect(aSocket: TLSocket);
   public
    constructor Create;
    function Send(srv:string; port:word; mailfrom,mailto,subj,data,att:string):boolean; // Отправить почту
    FQuit: Boolean;  // helper for main loop

  end;

implementation


{TSendMail}
procedure TSendMail.OnReceive(aSocket: TLSocket);
var
  s: string;
begin
  if FSMTP.GetMessage(s) > 0 then // if we actually received something from SMTP server, write it for the user
//    Write(s);
end;

procedure TSendMail.OnConnect(aSocket: TLSocket);
begin
//  Writeln('Connected'); // inform user of successful connect
  FConn:=true;
end;

procedure TSendMail.OnDisconnect(aSocket: TLSocket);
begin
//  Writeln('Lost connection'); // inform user about lost connection
  FQuit := True; // since SMTP shouldn't do this unless we issued a QUIT, consider it to be end of session and quit program
  FConn:=false;
end;

procedure TSendMail.OnError(const msg: string; aSocket: TLSocket);
begin
//  Writeln(msg); // inform about error
  FErr:=true;
  FQuit := True;
end;
{
procedure TSendMail.OnSSLConnect(aSocket: TLSocket);
begin
  Writeln('SSL handshake was successful');
end;
 }
constructor TSendMail.Create;
begin
  inherited;

  FQuit := False;
  FConn:=false;
  FErr:=false;
  FSMTP := TLSMTPClient.Create(nil);
//  FSMTP.Timeout := 100; // responsive enough, but won't hog CPU
  FSMTP.OnReceive := @OnReceive; // assign all events
  FSMTP.OnConnect := @OnConnect;
  FSMTP.OnDisconnect := @OnDisconnect;
  FSMTP.OnError := @OnError;
end;

{Отправка сообщения}
// data - текст письма
// att- имя прилагаемого файла
function TSendMail.Send(srv:string; port:word; mailfrom,mailto,subj,data,att:string):boolean;
var
//  s, Addr, Subject, Sender, Recipients, Message: string;
//  c: Char;
//  i,k:integer;
  FMimeStream: TMimeStream;
  Subject: string;
 // port:word;
begin
//  port:=25;
  Result:=false;
  FMimeStream:=TMimeStream.Create;
  FMimeStream.AddTextSection('');
  if FileExists(att) then FMimeStream.AddFileSection(att);
//  Write('Connecting to ', Addr, ':', Port, '... ');
   if FSMTP.Connect(srv, Port) then
    begin
    repeat  // try to connect
//    WriteLn('Wait connecting...');
//    WriteLog('Ждем подключения...',true);
    FSMTP.CallAction;  // if inital connect went ok, wait for "acknowlidgment" or otherwise
    until  Fconn or FErr; // ЖДем или обшику или подключение
    end;
    if FErr then exit; // ошибка подключения к серверу
   FSMTP.CallAction;
    FSMTP.Ehlo;
    FSMTP.CallAction;
      //Subject := Ansitoutf8(Subj);
      Subject := Subj;
      //Subject := Utf8ToAnsi(Subj);
       FMimeStream.Reset; // make sure we can read it again

       //TMimeTextSection(FMimeStream[0]).Text := Ansitoutf8(Data); // change to text
       TMimeTextSection(FMimeStream[0]).Text := Data; // change to text

       FSMTP.SendMail(mailfrom, mailto, Subject, FMimeStream); // send the mail given user data
//       WriteLog('Отправили письмо...',true);
       FSMTP.CallAction;
       FSMTP.Quit;
       FSMTP.CallAction;
    while FConn do
    begin
    //  FSMTP.Quit;
//      WriteLog('Ждем отключения...',true);
      FSMTP.CallAction;
    end;
//   WriteLog('Отключились...',true);
   FMimeStream.Destroy;
   Result:=true;//Ferr;//true;
 //  ReadLn;
end;


//=====================================================================



end.

