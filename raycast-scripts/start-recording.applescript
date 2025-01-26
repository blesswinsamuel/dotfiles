-- https://superuser.com/questions/612474/applescript-quicktime-start-and-stop-a-movie-recording-and-export-it-to-disk
(*********************************************
Record a Single `QuickTime` Movie
Args:
    1. name: The name of the movie.
    2. seconds: The length of the movie you want to record in seconds.
Usage:
    > osascript movie_record.scpt 'name' 5
    > osascript movie_record.scpt <file_name> <seconds>
**********************************************)
on run argv
    set audioFilePath to item 1 of argv
    set f to a reference to POSIX file audioFilePath

    tell application "QuickTime Player"
        activate
        set newAudioRecording to new audio recording

        tell newAudioRecording
            start

            -- with timeout of 9000 seconds
            --     display dialog "Click OK to stop recording" buttons {"OK"} default button "OK"
            -- end timeout
            delay 20

            pause
            save newAudioRecording in f
            stop
            close newAudioRecording
        end tell
    end tell
end run
