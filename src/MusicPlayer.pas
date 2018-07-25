program GameMain;
uses SwinGame, sgTypes, Sysutils;
type
  Track = record
    trackID: Integer;
    trackTitle: String;
    trackLocation: String;
  end;
  TrackArray = array [0..14] of Track;
 	Album = record
    albumID: Integer;
		albumTitle: String;
    artistName: String;
    artwork: String;
    numberOfTracks: Integer;
    albumTracks: TrackArray;
  end;
  AlbumArray = array [0..3] of Album;
var
  numberOfAlbums : Integer = 0;
  allAlbumsArray : AlbumArray;
  buttonStopX, buttonPlayX, buttonForwardX, buttonDimension, artworkDimX, artworkDimY : Single;
  artwork1X, artwork1Y : Single;
  artwork2X, artwork2Y : Single;
  artwork3X, artwork3Y : Single;
  artwork4X, artwork4Y : Single;
  widthArea, heightArea: Single;
  buttonControlY : Single;
  titleClickOrder: Integer;
  playlistAlbum: Album;

// Set Stop Button position
procedure SetPosition();
begin
  buttonStopX:= 398;
  buttonControlY:= 480;
  buttonPlayX := buttonStopX + 100;
  buttonForwardX := buttonStopX + 200;
  buttonDimension := 64;
  artworkDimX := 250;
  artworkDimY := 200;


  artwork1X := 20;
  artwork1Y := 20;

  artwork2X := 290;
  artwork2Y := 20;

  artwork3X := 20;
  artwork3Y := 240;

  artwork4X := 290;
  artwork4Y := 240;
end;

// Set area for clickable
procedure SetArea(xPos, yPos, widthDim, heightDim: Single);
begin
  widthArea := xPos + widthDim;
  heightArea := yPos + heightDim;
end;

// Readl lines by lines from file
procedure ReadLinesFromFile(myFileName: String);
var i: Integer = 0;
    j: Integer = 0;
    myFile: TextFile;
begin
 AssignFile(myFile, myFileName);
 {$I-} //disable i/o error checking
 Reset(myFile);
 {$I+} //enable i/o error checking again
 if (IOResult <> 0) then
   begin
      WriteLn('File ',myFileName,' is not found...');
   end else
   begin
     ReadLn(myFile, numberOfAlbums);
     repeat // Repeating reading albums
      allAlbumsArray[i].albumID := i + 1;
      ReadLn(myFile, allAlbumsArray[i].albumTitle);
      ReadLn(myFile, allAlbumsArray[i].artistName);
      ReadLn(myFile, allAlbumsArray[i].artwork);
      ReadLn(myFile, allAlbumsArray[i].numberOfTracks);
      repeat // Repeating reading tracks name and tracks locations
        allAlbumsArray[i].albumTracks[j].trackID := allAlbumsArray[i].albumID * 100 + j;
        ReadLn(myFile, allAlbumsArray[i].albumTracks[j].trackTitle);
        ReadLn(myFile, allAlbumsArray[i].albumTracks[j].trackLocation);
        LoadMusic(allAlbumsArray[i].albumTracks[j].trackLocation);


        WriteLn('Track title: ', allAlbumsArray[i].albumTracks[j].trackTitle);
        WriteLn('Track ID: ', allAlbumsArray[i].albumTracks[j].trackID);


        j := j + 1;
      until j = allAlbumsArray[i].numberOfTracks;
			j := 0;
      i := i + 1;
     until i = numberOfAlbums;
     Close(myFile);
   end;
end;

// ButtonClicked will get mouse position and return true if mouse clicked inside button's area
function ButtonClicked(buttonName:String): Boolean;
var
  buttonX: Single = -10;
  buttonY: Single = -10;
  mousePositionX, mousePositionY: Single;
begin
  mousePositionX := MouseX();
  mousePositionY := MouseY();
  case buttonName of
    'stop' :
      begin
        buttonX := buttonStopX;
        buttonY := buttonControlY;
        SetArea(buttonX, buttonY, buttonDimension, buttonDimension);
      end;
    'play' :
      begin
        buttonX := buttonPlayX;
        buttonY := buttonControlY;
        SetArea(buttonX, buttonY, buttonDimension, buttonDimension);
      end;
    'forward' :
      begin
        buttonX := buttonForwardX;
        buttonY := buttonControlY;
        SetArea(buttonX, buttonY, buttonDimension, buttonDimension);
      end;
    'artwork1' :
      begin
        buttonX := artwork1X;
        buttonY := artwork1Y;
        SetArea(buttonX, buttonY, artworkDimX, artworkDimY);
      end;
    'artwork2' :
      begin
        buttonX := artwork2X;
        buttonY := artwork2Y;
        SetArea(buttonX, buttonY, artworkDimX, artworkDimY);
      end;
    'artwork3' :
      begin
        buttonX := artwork3X;
        buttonY := artwork3Y;
        SetArea(buttonX, buttonY, artworkDimX, artworkDimY);
      end;
    'artwork4' :
      begin
        buttonX := artwork4X;
        buttonY := artwork4Y;
        SetArea(buttonX, buttonY, artworkDimX, artworkDimY);
      end;
      else buttonX := -10;
  end;
  result := false;
  if MouseClicked(LeftButton) then
    begin
      if (mousePositionX >= buttonX) and (mousePositionX <= widthArea) then
        begin
          if (mousePositionY >= buttonY) and (mousePositionY <= heightArea) then
            begin
              result := true;
            end;
        end;
    end;
    widthArea := 0;
    heightArea := 0;
end;

// Click Track Title --> Click to trackTitle then return trackID
function trackTitleClicked(playingAlbumInput: Album; titlePosition: String): Integer;
var
mousePositionX, mousePositionY: Single;
widthAreaTest, heightAreaTest: Single;
buttonX, buttonY: Single;
i: Integer;
begin
  case titlePosition of
    'Album':
      begin
        buttonX := 580;
      end;
    'Playlist':
      begin
        buttonX := 820;
      end;
  end;
  buttonY := 38;
  widthAreaTest := buttonX + 130;
  mousePositionX := MouseX();
  mousePositionY := MouseY();
  result := -1;
  for i:= 0 to (playingAlbumInput.numberOfTracks - 1) do
    begin
      heightAreaTest := buttonY + 14;
      if MouseClicked(LeftButton) then
        begin
          if (mousePositionX >= buttonX) and (mousePositionX <= widthAreaTest) then
            begin
              if (mousePositionY >= buttonY) and (mousePositionY <= heightAreaTest) then
                begin
                  result := playingAlbumInput.albumTracks[i].trackID;
                end;
                buttonY := buttonY + 28;
            end;
        end;
    end;
    heightAreaTest := buttonY + 14;
end;


// Check if trackId exist in playlistAlbum.albumTracks
function TrackOrderInPlaylist(trackIdInput: Integer): Integer;
var i: Integer;
begin
  result := -1;
  if (playlistAlbum.numberOfTracks >= 0) and (playlistAlbum.numberOfTracks <= 15) then
    begin
      for i := 0 to (playlistAlbum.numberOfTracks - 1) do
        begin
          if (trackIdInput = playlistAlbum.albumTracks[i].trackId) then
            result := i;
        end;
    end;
end;

// Click Add arrow --> return trackID
function AddToPlaylist(playingAlbumInput: Album): Integer;
var
mousePositionX, mousePositionY: Single;
widthAreaTest, heightAreaTest: Single;
buttonX, buttonY: Single;
i: Integer;
begin
  buttonX := 780;
  buttonY := 38;
  widthAreaTest := buttonX + 20;
  mousePositionX := MouseX();
  mousePositionY := MouseY();
  result := -1;
  if (playlistAlbum.numberOfTracks < 15) then
    begin
      for i:= 0 to (playingAlbumInput.numberOfTracks - 1) do
        begin
          heightAreaTest := buttonY + 14;
          if MouseClicked(LeftButton) then
            begin
              if (mousePositionX >= buttonX) and (mousePositionX <= widthAreaTest) then
                begin
                  if (mousePositionY >= buttonY) and (mousePositionY <= heightAreaTest) then
                    begin
                        result := playingAlbumInput.albumTracks[i].trackID;
                    end;
                    buttonY := buttonY + 28;
                end;
            end;
        end;
    end;
    heightAreaTest := buttonY + 14;
end;


// Click remove  --> Click to remove then return trackID to be removed
function RemoveFromPlaylist(): Integer;
var
mousePositionX, mousePositionY: Single;
widthAreaTest, heightAreaTest: Single;
buttonX, buttonY: Single;
i: Integer;
begin
  buttonX := 1000;
  buttonY := 42;
  widthAreaTest := buttonX + 10;
  mousePositionX := MouseX();
  mousePositionY := MouseY();
  result := -1;
  for i:= 0 to (playlistAlbum.numberOfTracks - 1) do
    begin
      heightAreaTest := buttonY + 10;
      if MouseClicked(LeftButton) then
        begin
          if (mousePositionX >= buttonX) and (mousePositionX <= widthAreaTest) then
            begin
              if (mousePositionY >= buttonY) and (mousePositionY <= heightAreaTest) then
                begin
                  result := playlistAlbum.albumTracks[i].trackID;
                end;
                buttonY := buttonY + 28;
            end;
        end;
    end;
    heightAreaTest := buttonY + 10;
end;


// Find Album by trackID
function GetAlbumByTrackId(trackIdInput: Integer): Album;
var i,j: Integer;
    countSearch: Integer = 0;
    albumReturn: Album;
begin
  for i:=0 to High(allAlbumsArray) do
    begin
      for j:=0 to allAlbumsArray[i].numberOfTracks do
        begin
          if allAlbumsArray[i].albumTracks[j].trackID = trackIdInput then
            begin
              albumReturn := allAlbumsArray[i];
              countSearch := countSearch + 1;
            end
        end;
    end;
    if countSearch = 0 then
  	begin
  		albumReturn.albumID:= -1;
  		WriteLn('Sorry not found');
  	end;
    result:= albumReturn;
end;

// Find track by trackID
function GetTrackById(trackIdInput: Integer): Track;
var i: Integer;
    countSearch: Integer = 0;
    trackReturn: Track;
    albumHelper: Album;
begin
  albumHelper := GetAlbumByTrackId(trackIdInput);
  for i:=0 to albumHelper.numberOfTracks do
    begin
      if albumHelper.albumTracks[i].trackID = trackIdInput then
        begin
          trackReturn := albumHelper.albumTracks[i];
          countSearch := countSearch + 1;
        end
    end;
    if countSearch = 0 then
  	begin
  		trackReturn.trackID:= -1;
  		WriteLn('Sorry no track found');
  	end;
    result:= trackReturn;
end;

// Playing Music by trackID
procedure PlayMusicByTrackID(trackIdInput: Integer);
begin
  PlayMusic(GetTrackById(trackIdInput).trackLocation);
end;

// Draw Playing text
procedure DrawPlayingText(text: String);
var stringDisplay: String;
begin
  if MusicPlaying() then
    begin
      stringDisplay := 'Now playing ' + text;
      DrawText(stringDisplay, ColorBlack, 'montserrat.ttf', 14, 425, 555);
    end else
    begin
      stringDisplay := 'Please choose music to play';
      DrawText(stringDisplay, ColorBlack, 'montserrat.ttf', 14, 425, 555);
    end;
end;

// Draw Album name
procedure DrawalbumTitle(text: String);
begin
  DrawText(text, ColorBlack, 'montserrat.ttf', 20, 580, 5);
  DrawText('Playlist', ColorBlack, 'montserrat.ttf', 20, 820, 5);
end;

// Draw Tracks title
procedure DrawtrackTitle(playingAlbumInput: Album; trackPlayingIDInput: Integer);
var
  i: Integer;
  space: Integer = 28;
begin
  for i:=0 to (playingAlbumInput.numberOfTracks - 1) do
    begin
      DrawText(playingAlbumInput.albumTracks[i].trackTitle, ColorBlack, 'montserrat.ttf', 14, 580, (10 + space));
      DrawText('->', ColorBlack, 'montserrat.ttf', 14, 780, (10 + space));
      space := space + 28;
    end;
    space := 28;
end;

// Draw Playlist title
procedure DrawPlaylistTitle();
var
  i: Integer;
  space: Integer = 28;
begin
  for i:=0 to (playlistAlbum.numberOfTracks - 1) do
    begin
      DrawText(playlistAlbum.albumTracks[i].trackTitle, ColorBlack, 'montserrat.ttf', 14, 820, (10 + space));
      LoadBitmapNamed('remove' ,'remove.png' );
      DrawBitmap( 'remove', 1000, (14 + space) );
      space := space + 28;
    end;
    space := 28;
end;


// Draw screen
procedure DrawScreen();
begin
  SetPosition();
  // Draw button
  LoadBitmapNamed('stop' ,'stop.png' );
  DrawBitmap( 'stop', buttonStopX, buttonControlY );
  LoadBitmapNamed('play' ,'play.png' );
  DrawBitmap( 'play', buttonPlayX, buttonControlY );
  LoadBitmapNamed('forward' ,'forward.png' );
  DrawBitmap( 'forward', buttonForwardX, buttonControlY );

  //Draw artwork
  LoadBitmapNamed('album1' ,allAlbumsArray[0].artwork );
  DrawBitmap('album1', artwork1X, artwork1Y );
  LoadBitmapNamed('album2' ,allAlbumsArray[1].artwork );
  DrawBitmap('album2', artwork2X, artwork2Y );
  LoadBitmapNamed('album3' ,allAlbumsArray[2].artwork );
  DrawBitmap('album3', artwork3X, artwork3Y );
  LoadBitmapNamed('album4' ,allAlbumsArray[3].artwork );
  DrawBitmap('album4', artwork4X, artwork4Y );

  // Draw horizontal line
  DrawLine(ColorBlack, 0, 460, 1020, 460);

  // Draw first vertical line
  DrawLine(ColorBlack, 560, 0, 560, 460);
  // Draw second vertical line
  DrawLine(ColorBlack, 800, 0, 800, 460);
end;

procedure ResetPlaylistAlbum();
var i: Integer;
begin
  playlistAlbum.albumID := 5000;
  playlistAlbum.albumTitle := 'Playlist';
  playlistAlbum.artistName := 'Customize';
  playlistAlbum.artwork := 'customize.png';
  playlistAlbum.numberOfTracks := 0;
  for i := 0 to 14 do
    playlistAlbum.albumTracks[i].trackID := playlistAlbum.albumTracks[i+1].trackID;
  playlistAlbum.albumTracks[14].trackID := 0;
end;

procedure DeleteInPlaylistArray(position: Integer);
var
  i, max: Integer;
begin
  if (playlistAlbum.numberOfTracks = 15) then max := 14 else max := playlistAlbum.numberOfTracks;
  for i := position to (max - 1) do
    playlistAlbum.albumTracks[i] := playlistAlbum.albumTracks[i+1];
  playlistAlbum.albumTracks[14].trackID := 0;
  playlistAlbum.numberOfTracks:= playlistAlbum.numberOfTracks - 1;
end;

procedure Main();
var
  screenColor: Color;
  albumTitleDisplay: String;
  trackTitleDisplay: TrackArray;
  fileName: String;
  trackPlayingID: Integer = 0;
  playingText: String;
  playingAlbum: Album;
  numberOfForward: Integer = 0;
  loopInAlbum: Integer = 0;
begin
  OpenAudio();
  OpenGraphicsWindow('Music Player', 1020, 600);
  ReadLinesFromFile('album.dat');
  trackPlayingID := allAlbumsArray[0].albumTracks[0].trackID;
  albumTitleDisplay := allAlbumsArray[0].albumTitle;
  playingText := GetTrackById(trackPlayingID).trackTitle;
  playingAlbum := allAlbumsArray[0];
  ResetPlaylistAlbum();
  repeat
    ClearScreen(ColorWhite);
    DrawScreen();
    ProcessEvents();
    //Clicked Control Button
    if ButtonClicked('stop') then
      begin
        WriteLn('Clicked Stop');
        StopMusic();
      end;
    if ButtonClicked('play') then
      begin
        PlayMusicByTrackID(trackPlayingID);
        playingText := GetTrackById(trackPlayingID).trackTitle;
        WriteLn('Clicked Play, trackTitle: ', GetTrackById(trackPlayingID).trackTitle);
      end;
    if ButtonClicked('forward') then
      begin
        trackPlayingID := trackPlayingID + 1;
        if trackPlayingID <= playingAlbum.albumTracks[(playingAlbum.numberOfTracks - 1)].trackID then
          begin
            PlayMusicByTrackID(trackPlayingID);
            playingText := GetTrackById(trackPlayingID).trackTitle;
          end else
          begin
            trackPlayingID := trackPlayingID - 1;
            PlayMusicByTrackID(trackPlayingID);
            playingText := GetTrackById(trackPlayingID).trackTitle;
          end;
        WriteLn('Clicked Forward, trackTitle: ', GetTrackById(trackPlayingID).trackTitle);
      end;
    // Clicked artwork
    if ButtonClicked('artwork1') then
      begin
        WriteLn('Clicked artwork1');
        trackPlayingID := allAlbumsArray[0].albumTracks[0].trackID;
        albumTitleDisplay := allAlbumsArray[0].albumTitle;
        playingAlbum := allAlbumsArray[0];
      end;
    if ButtonClicked('artwork2') then
      begin
        WriteLn('Clicked artwork2');
        trackPlayingID := allAlbumsArray[1].albumTracks[0].trackID;
        albumTitleDisplay := allAlbumsArray[1].albumTitle;
        playingAlbum := allAlbumsArray[1];
      end;
    if ButtonClicked('artwork3') then
      begin
        WriteLn('Clicked artwork3');
        trackPlayingID := allAlbumsArray[2].albumTracks[0].trackID;
        albumTitleDisplay := allAlbumsArray[2].albumTitle;
        playingAlbum := allAlbumsArray[2];
      end;
    if ButtonClicked('artwork4') then
      begin
        WriteLn('Clicked artwork4');
        trackPlayingID := allAlbumsArray[3].albumTracks[0].trackID;
        albumTitleDisplay := allAlbumsArray[3].albumTitle;
        playingAlbum := allAlbumsArray[3];
      end;
    if trackTitleClicked(playingAlbum, 'Album') > 0 then
      begin
        trackPlayingID := trackTitleClicked(playingAlbum, 'Album');
        PlayMusicByTrackID(trackPlayingID);
        playingText := GetTrackById(trackPlayingID).trackTitle;
        WriteLn('Clicked on Title, trackTitle: ', GetTrackById(trackPlayingID).trackTitle);
      end;
    if (AddToPlaylist(playingAlbum) > 0) and (TrackOrderInPlaylist(AddToPlaylist(playingAlbum)) < 0) then
      begin
        playlistAlbum.albumTracks[playlistAlbum.numberOfTracks] := GetTrackById(AddToPlaylist(playingAlbum));
        WriteLn('Clicked on playlist arrow, trackTitle: ', GetTrackById(AddToPlaylist(playingAlbum)).trackTitle);
        playlistAlbum.numberOfTracks := playlistAlbum.numberOfTracks + 1;
      end;
    if (RemoveFromPlaylist() > 0) then
    begin
      WriteLn('Clicked on remove, with trackID: ', RemoveFromPlaylist());
      WriteLn('Track order ', TrackOrderInPlaylist(RemoveFromPlaylist()));
      DeleteInPlaylistArray(TrackOrderInPlaylist(RemoveFromPlaylist()));
    end;
    if trackTitleClicked(playlistAlbum, 'Playlist') > 0 then
      begin
        loopInAlbum := TrackOrderInPlaylist(trackTitleClicked(playlistAlbum, 'Playlist'));
        trackPlayingID := playlistAlbum.albumTracks[loopInAlbum].trackID;
        PlayMusicByTrackID(trackPlayingID);
        playingText := GetTrackById(trackPlayingID).trackTitle;
        WriteLn('Clicked on Playlist Title, trackTitle: ', GetTrackById(trackPlayingID).trackTitle);
        WriteLn('loopInAlbum: ', loopInAlbum);
      end;
    DrawalbumTitle(albumTitleDisplay);
    DrawtrackTitle(playingAlbum, trackPlayingID);
    DrawPlayingText(playingText);
    DrawPlaylistTitle();
    RefreshScreen( 60 );
  until WindowCloseRequested();
  CloseAudio();
  ReleaseAllResources();
end;

begin
  Main();
end.
