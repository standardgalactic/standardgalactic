; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include RandomFunctions.ahk 
#Include AutoCorrect.ahk
#Include RandomNameGenerator.ahk

;;#Include Gdp_All.ahk
;;#Include tosga.ahk ;; Alt + home to toggle, may be inconvenient
;#Include vim-scripts.ahk ;; toggle with windows+v ;; wow that was annoying

;; AutoHotkey script to Open, Restore or Minimize
;; any Apps using the hotkeys you want
;; -- by JuanmaMenendez --

;; Alt+`(backtick) to switch between windows of the same type, eg. chrome, notepad

#Include AutoHotkey-script-Open-Show-Apps.ahk
;#Include AutoHotkey-script-Switch-Windows-same-App.ahk


/*
::slowtype::CPM=4400; DELAY=$(echo "scale=3; 60 / $CPM" | bc); while IFS= read -r -n1 char; do printf "%s" "$char"; [ "$char" = $'\n' ] && printf "\n"; sleep $DELAY; done < 

::psy cin::CPM=4400; DELAY=$(echo "scale=3; 60 / $CPM" | bc); while IFS= read -r -n1 char; do printf "%s" "$char"; [ "$char" = $'\n' ] && printf "\n"; sleep $DELAY; done < psychocinema-summary.txt;;;;;;; SROLL READER ;;;;;;;;
*/

;; For thematic parsing and critical decoding of cinema ;;

::so big summary::pv -q -L 33 < so-big-summary.txt

/*
::so big summary::CPM=4400; DELAY=$(echo "scale=3; 60 / $CPM" | bc); while IFS= read -r -n1 char; do printf "%s" "$char"; [ "$char" = $'\n' ] and printf "\n"; sleep $DELAY; done < so-big-summary.txt

The narrative script, *So Big*, exhibits an engineered transition of Selina from metropolitan elegance to agrarian drudgery, symbolically compiled as an effort to farm value from personal sacrifice. This module, viewed through SPROLL READER, enhances the linear decoding of narrative data, processing Selina's character development from cultural sophistication to agricultural resilience. Each byte of text unspools her ideological recompilation from socialite to soil-tender, her shifts encoded within a cinematic interface that marries pastoral binaries with urban binaries—ideal for SPROLL's temporal dilation capabilities.

Viewers can adjust textual output velocity to reflect on how the film's programming converts personal sacrifices into societal virtues, an algorithm of existential computation. This strategic reading pace allows a deeper system-level analysis of the film's socio-economic commentary, facilitated by customized font rendering to enhance cognitive engagement and aesthetic processing.

See also:
https://archive.org/details/so-big-1953
*/

;;;;;;;;;;;;;;;;;;;;;;;;


::checkdup::find . -type f -name "*.m4a" -exec bash -c '[[ -f "${1%.m4a}.mp3" ]] && echo "Matching MP3 found for: $1" || echo "No matching MP3 for: $1"' bash {} \;


::clearprogress::find . -type f \( -name 'overview.txt' -o -name 'progress.log' \) -delete


::?txt::ls -1 *.txt | wc -l

::?lines::find . -type f -name "*.txt" -exec sh -c 'lines=$(wc -l < "{}"); [ "$lines" -gt 200 ] && echo "{}: $lines"' \;

;; how many overviews ;;

::?count::ls -1 *-overview.txt 2>/dev/null | wc -l


;; Autohotkey shortcut - get subtitles

::updatewhisper::pip install --upgrade --no-deps --force-reinstall git+https://github.com/openai/whisper.git

::wspr::
(

    for file in *.mp3; do
        if [ -f "$file" ] && [ ! -f "${file%.*}.txt" ]; then
            whisper "$file"
        fi
    done
)
Return


::getsubs::
(
find . -maxdepth 1 \( -type d -o -type f \( -name "*.mp3" -o -name "*.m4a" -o -name "*.webm" \) \) -print0 | while IFS= read -r -d '' item; do
  if [ -d "$item" ]; then
    cd "$item" || continue
    for file in *.mp3 *.m4a *.webm; do
      [ -f "$file" ] && [ ! -f "${file%.*}.txt" ] && whisper "$file" --language English
    done
    cd ..
  elif [ -f "$item" ] && [ ! -f "${item%.*}.txt" ]; then
    whisper "$item" --language English
  fi
done`n
)
return



::getsubs -v::
(
find . -maxdepth 1 -type d -exec sh -c '
shopt -s nullglob
for dir in "$@"; do
    echo "Attempting to enter directory: $dir"
    if cd "$dir"; then
        echo "Entered directory: $dir"
        # Process files in each directory
        for file in *.mp3 *.m4a *.webm; do
            echo "Found file: $file"
            if [ -f "$file" ] && [ ! -f "${file%.*}.txt" ]; then
                echo "Processing file: $file"
                # Timeout if whisper takes more than 10 minutes (600 seconds)
                timeout 600 whisper "$file" || echo "Timeout or failure in processing $file"
            fi
        done
        cd - >/dev/null
    else
        echo "Failed to enter directory: $dir"
    fi
done
' sh {} +`n
)
return

::logsubs::
(
find . -maxdepth 1 -type d -exec sh -c '
shopt -s nullglob
logfile="whisper_errors.log"
for dir in "$@"; do
    echo "Attempting to enter directory: $dir"
    if cd "$dir"; then
        echo "Entered directory: $dir"
        # Process files in each directory
        for file in *.mp3 *.m4a *.webm; do
            echo "Found file: $file"
            if [ -f "$file" ] && [ ! -f "${file%.*}.txt" ]; then
                echo "Processing file: $file"
                # Timeout if whisper takes more than 10 minutes (600 seconds)
                if ! timeout 600 whisper "$file" >"${file%.*}.txt" 2>>"$logfile"; then
                    echo "Timeout or failure in processing $file, see $logfile for details"
                fi
            fi
        done
        cd - >/dev/null
    else
        echo "Failed to enter directory: $dir" >>"$logfile"
    fi
done
' sh {} +`n
)
return


;; ::getsubs::find . -maxdepth 1 -type d -exec sh -c 'cd "{}" && whisper *' \;

;; ::getsubs::find . -maxdepth 1 -type d -exec sh -c 'cd "{}" && find . -maxdepth 1 -type f -exec whisper {} \;' \;



::getvids::yt-dlp -f best -ciw https://www.youtube.com/@tetasao --extract-audio --audio-format mp3 --audio-quality 0 --socket-timeout 5 --output "%(uploader)s/%(title)s.%(ext)s"

::getmp3s::yt-dlp -f best -ciw https://www.youtube.com/@timsanderson4076 --extract-audio --audio-format mp3 --audio-quality 0 --socket-timeout 5 --output "%(uploader)s/%(title)s.%(ext)s"

:*:cd..::cd ..

::get ollama::curl -fsSL https://ollama.com/install.sh | sh

::chec::ollama run vanilj/phi-4

::re call::
(
for file in *.txt; do
    echo "Checking $file";
    ollama run llama2 "Summarize:" < "$file";
done
)
return


::clean  up::
(
output_file="summaries.txt"
: > "$output_file" # Clear the output file if it exists

# Rename all non-txt files to have a .txt extension
for file in *; do
    if [[ "$file" != *.txt ]]; then
        mv "$file" "$file.txt"
    fi
done

# Summarize all txt files
for file in *.txt; do
    if [ "$file" == "$output_file" ]; then
#        echo "Skipping output file: $file" >> "$output_file"
        continue # Skip the summaries file itself
    fi

    if [ ! -s "$file" ]; then
#        echo "Skipping empty file: $file" >> "$output_file"
        continue # Skip summarizing if the file is empty
    fi

    # echo "Checking $file" | tee -a "$output_file"
    # echo "=== Summary for $file ===" | tee -a "$output_file"
    ollama run vanilj/phi-4 "Clean up the spelling mistakes and grammar. Remove unnecessary notes and page numbers. Don't give any explanation of what you are doing or add boilerplate:" < "$file" | tee -a "$output_file"
    echo -e "\n" | tee -a "$output_file" # Add a blank line between summaries
done`n
)
return

::onlytext::find . -type f ! -name '*.txt' -exec rm -f {} +

::addmhtml::
(
for file in *; do
  if [[ -f "$file" && "$file" != *.txt && "$file" != *.* ]]; then
    mv "$file" "$file.mhtml"
  fi
done`n
)
return


::addtxt::
(
for file in *; do
  if [[ -f "$file" && "$file" != *.txt && "$file" != *.* ]]; then
    mv "$file" "$file.txt"
  fi
done`n
)
return

::addtext::
(
for dir in */; do
  (cd "$dir" && for file in *; do
    [[ "$file" != *.txt && "$file" != *.* ]] && mv "$file" "$file.txt"
  done)
done`n
)
return


::notxt::
(
for file in *.txt; do
    mv "$file" "${file%.txt}"
done`n
)
return

::into100::split -d -l 100

::re cap::
(
output_file="overview.txt"

# Summarize all txt files

for file in {*.vtt,*.txt}; do
    if [ "$file" == "$output_file" ]; then
        echo "Skipping output file: $file" >> "$output_file"
        continue # Skip the summaries file itself
    fi

    if [ ! -s "$file" ]; then
        echo "Skipping empty file: $file" >> "$output_file"
        continue # Skip summarizing if the file is empty
    fi

    echo "Checking $file" | tee -a "$output_file"
    echo "=== Summary for $file ===" | tee -a "$output_file"
    ollama run vanilj/phi-4 "Summarize in detail and explain:" < "$file" | tee -a "$output_file"
    echo -e "\n" | tee -a "$output_file" # Add a blank line between summaries
done`n
)
return

::fileoverview::
(
output_file="file-overview.txt"
: > "$output_file" # Clear the output file if it exists

# Summarize only text files
for file in *; do
    # Skip the output file itself
    if [ "$file" == "$output_file" ]; then
        echo "Skipping output file: $file" >> "$output_file"
        continue
    fi

    # Skip empty files
    if [ ! -s "$file" ]; then
        echo "Skipping empty file: $file" >> "$output_file"
        continue
    fi

    # Check if the file is a text file
    if ! file --mime-type "$file" | grep -q 'text'; then
        echo "Skipping non-text file: $file" >> "$output_file"
        continue
    fi

    # Summarize the file
    echo "Checking $file" | tee -a "$output_file"
    echo "=== Summary for $file ===" | tee -a "$output_file"
    ollama run vanilj/phi-4 "Summarize in detail and explain:" < "$file" | tee -a "$output_file"
    echo -e "\n" | tee -a "$output_file" # Add a blank line between summaries
done`n
)
return

:*:run phi::ollama run vanilj/phi-4`n

::nomath::
(
output_file="overview.txt"
: > "$output_file" # Clear the output file if it exists

# Rename all non-txt files to have a .txt extension
for file in *; do
    if [[ "$file" != *.txt ]]; then
        mv "$file" "$file.txt"
    fi
done

# Summarize all txt files
for file in *.txt; do
    if [ "$file" == "$output_file" ]; then
        echo "Skipping output file: $file" >> "$output_file"
        continue # Skip the summaries file itself
    fi

    if [ ! -s "$file" ]; then
        echo "Skipping empty file: $file" >> "$output_file"
        continue # Skip summarizing if the file is empty
    fi

    echo "Checking $file" | tee -a "$output_file"
    echo "=== Summary for $file ===" | tee -a "$output_file"
    ollama run vanilj/phi-4 "Without using latex or special notation, summarize  in detail and explain. Give glossaries to describe in ordinary english, using analogies and metaphors wherever possible. Kindergarten to high-school definitions of terms:" < "$file" | tee -a "$output_file"
    echo -e "\n" | tee -a "$output_file" # Add a blank line between summaries
done`n
)
return

::getmeta::ls -latrh *.mp3 > metadata.txt

;; open current directory

^e::Send, explorer.exe .`n



;;;;;;; SROLL READER ;;;;;;;;

;; For reading Quadrivium ;;
;; https://github.com/standardgalactic/quadrivium ;;

::slowtype::pv -q -L 110 < 

::slow c::for file in *critique.txt; do pv -q -L 80 < "$file"; done
::slow s::for file in *sardonic.txt; do pv -q -L 80 < "$file"; done
::slow o::for file in *overview.txt; do pv -q -L 80 < "$file"; done

::psy cin::pv -q -L 110 < psychocinema-summary.txt

::psycho cin::pv -q -L 110 < psychocinema-summary.txt
::reel slow::
SetKeyDelay, 50, 50 ; Increase delay for reliability
originalLCID := DllCall("GetKeyboardLayout", "UInt", 0)
englishLCID := 0x0409
DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", englishLCID), "Int", 1)

SendInput, vim reel-slow.sh`n
Sleep, 300
SendInput, i ; Enter insert mode
Sleep, 100
SendInput, #
Sleep, 50
SendInput, !
Sleep, 50
SendInput, /bin/bash`n
scriptContent =
(
# Initial speed`n
speed=40`n
`n
# Function to update speed and direction`n
update_speed() {`n
  case "$1" in`n
    up) ((speed += 20)) ;;`n
    down) ((speed -= 20)) ;;`n
    left) speed=-$speed ;;`n
    right) speed=${speed#-} ;;`n
  esac`n
}`n
`n
# Trap key events`n
trap 'update_speed up' SIGUSR1`n
trap 'update_speed down' SIGUSR2`n
trap 'update_speed left' SIGTERM`n
trap 'update_speed right' SIGINT`n
`n
# Background process to read keys`n
{`n
  while true; do`n
    read -n1 key`n
    case "$key" in`n
      A) kill -SIGUSR1 $$ ;; # Up arrow`n
      B) kill -SIGUSR2 $$ ;; # Down arrow`n
      D) kill -SIGTERM $$ ;; # Left arrow`n
      C) kill -SIGINT $$ ;; # Right arrow`n
    esac`n
  done`n
} &`n
`n
# Process the files`n
for file in *sardonic.txt; do`n
  while read -r line; do`n
    pv -q -L "$speed" <<< "$line"`n
  done < "$file"`n
done`n
`n
# Wait for the background process to end`n
wait
)
SendInput, %scriptContent%
Sleep, 100
SendInput, {Escape}
Sleep, 100
SendInput, :wq`n
Sleep, 100 ; Add additional sleep before running the script.
SendInput, ./reel-slow.sh`n

DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", originalLCID), "Int", 1)
SetKeyDelay, 10, 10
Return

::re caps::
(
find . -type f -name "*.txt" | while IFS= read -r file
do
    echo "Checking $file"
    # Run the ollama command on the file and output the results to the terminal
    ollama run mistral "Summarize:" < "$file"
done
)
return


;; zoological xenoglossia comparison and verification

:*:wizz::
(
for file in *.txt; do
    echo "Checking $file";
    ollama run wizardlm2 "Summarize:" < "$file";
done`n
)
return

::getoverview::
(
summary_file="overview.txt"
progress_file="progress.log"

main_dir=$(pwd)

# Function to check if a file is already processed
is_processed() {
    grep -Fxq "$1" "$main_dir/$progress_file"
}

# Create progress file if it doesn't exist
touch "$main_dir/$progress_file"

# Process text files in the given directory
process_files() {
    local dir="$1"
    echo "Processing directory: $dir"

    # Iterate over each .txt file in the specified directory
    for file in "$dir"/*.txt; do
        if [ -f "$file" ]; then
            file_path=$(realpath "$file") # Use realpath to get the full file path
            if ! is_processed "$file_path"; then
                echo "Checking $file"
                echo "Checking $file" >> "$main_dir/$summary_file"

                ollama run wizardlm2 "Summarize:" < "$file" | tee -a "$main_dir/$summary_file"
=======
# Iterate over each .txt file in the current directory
for file in *.txt; do
    if [ -f "$file" ]; then
        file_path=$(pwd)/"$file"
        if ! is_processed "$file_path"; then
            echo "Checking $file"
            echo "Checking $file" >> "$main_dir/$summary_file"

            ollama run wizardlm2 "Summarize:" < "$file" | tee -a "$main_dir/$summary_file"
            echo "$file_path" >> "$main_dir/$progress_file"
        fi
    fi
done`n
)
return

::getsummaries::
(
summary_file="overview.txt"
progress_file="progress.log"
main_dir=$(pwd)

echo "Script started at $(date)" >> "$main_dir/$progress_file"
echo "Summaries will be saved to $summary_file" >> "$main_dir/$progress_file"

# Function to process text files
process_files() {
    echo "Processing directory: $1"
    
    # Iterate over each .txt file in the specified directory
    for file in "$1"/*.md; do
        # Skip if the glob didn't match or if file doesn't exist
        if [ ! -e "$file" ]; then
            continue
        fi
        
        if [ -f "$file" ]; then
            file_path=$(realpath "$file")  # Get absolute path of the file
            
            # Process only if not processed before
            if ! is_processed "$file_path"; then
                echo "Processing $file"
                echo "Processing $file" >> "$main_dir/$progress_file"
                
                # Summarize the file and append to the summary file while displaying to terminal
                ollama run vanilj/phi-4 "Summarize:" < "$file" | tee -a "$main_dir/$summary_file"
                echo "$file_path" >> "$main_dir/$progress_file"
            fi
        fi
    done
}

# Recursively process subdirectories
process_subdirectories() {
    for dir in "$1"/*/; do
        if [ -d "$dir" ]; then
            process_files "$dir"  # Process files in the subdirectory
            process_subdirectories "$dir"  # Recursive call for further subdirectories
        fi
    done
}

# Main execution
process_files "$main_dir"  # Process files in the main directory
process_subdirectories "$main_dir"  # Process files in subdirectories

echo "Script completed at $(date)" >> "$main_dir/$progress_file"`n
)
return

::makehol::
(
cat > holize.sh << 'EOF'
#!/usr/bin/bash

# Paths to required files
summary_file="summaries.txt"
holistic_summary_file="holistic-summaries.txt"
progress_file="progress.log"
main_dir=$(pwd)

# Ensure progress and summary files exist
touch "$main_dir/$progress_file"
touch "$main_dir/$summary_file"
touch "$main_dir/$holistic_summary_file"

# Extract the "summary of summaries" from summaries.txt
summary_of_summaries=$(grep -A1000 "===== Summaries for" "$summary_file" | tail -n +2)

# Start logging
echo "Starting holistic summarization process at $(date)" >> "$main_dir/$progress_file"

# Iterate over each .txt file in the directory, excluding specified files
for file in "$main_dir"/*.txt; do
    # Skip summaries.txt and holistic-summaries.txt explicitly
    if [[ "$(basename "$file")" == "$(basename "$summary_file")" || "$(basename "$file")" == "$(basename "$holistic_summary_file")" ]]; then
        echo "Skipping $file" >> "$main_dir/$progress_file"
        continue
    fi

    # Process all other .txt files
    if [ -f "$file" ]; then
        file_path=$(realpath "$file")
        
        # Process only if not processed before
        if ! grep -Fxq "$file_path" "$main_dir/$progress_file"; then
=======
# Iterate over each .txt file in the current directory
for file in "$main_dir"/*.txt; do
    # Check if the glob didn't match or if file doesn't exist
    if [ ! -e "$file" ]; then
        continue
    fi
    
    if [ -f "$file" ]; then
        file_path=$(realpath "$file")  # Get absolute path of the file
        
        # Process only if not processed before
        if ! is_processed "$file_path"; then

            # Summarize each chunk with the "summary of summaries" as context
            for chunk_file in "$temp_dir"/chunk_*; do
                [ -f "$chunk_file" ] || continue
                
                # Read chunk content
                chunk_content=$(cat "$chunk_file")
                
                # Combine context and chunk
                combined_input="Here is an overall summary of previous summaries: 
$summary_of_summaries

Now, summarize this chunk:
$chunk_content"
                
                # Summarize the chunk and append to holistic-summaries.txt
                echo "Summarizing chunk $(basename "$chunk_file") with additional context"
                echo "$combined_input" | ollama run vanilj/phi-4 | tee -a "$main_dir/$holistic_summary_file"
                echo "" | tee -a "$main_dir/$holistic_summary_file"
=======
            # Mention the file name before summarizing its chunks
            echo ""
            echo "Summarizing file: $file"
            echo "===== Summaries for $file =====" | tee -a "$main_dir/$summary_file"
            
            # Summarize each chunk without mentioning chunk names
            for chunk_file in "$temp_dir"/chunk_*; do
                [ -f "$chunk_file" ] || continue
                # Summarize the chunk and append directly to the summary file while also displaying to terminal
                ollama run vanilj/phi-4 "Summarize" < "$chunk_file" | tee -a "$main_dir/$summary_file"
                echo "" | tee -a "$main_dir/$summary_file"

            done
            
            # Remove the temporary directory
            rm -rf "$temp_dir"
            echo "Temporary directory $temp_dir removed" >> "$main_dir/$progress_file"
            
            # Mark the file as processed
            echo "$file_path" >> "$main_dir/$progress_file"
# Function to process text files
process_files() {
    echo "Processing directory: $1"
    
    # Iterate over each .txt file in the specified directory
    for file in "$1"/*.txt; do
        # Skip if the glob didn't match or if file doesn't exist
        if [ ! -e "$file" ]; then
            continue
        fi
        
        if [ -f "$file" ]; then
            file_path=$(realpath "$file")  # Get absolute path of the file
            
            # Process only if not processed before
            if ! is_processed "$file_path"; then
                echo "Processing $file"
                echo "Processing $file" >> "$main_dir/$progress_file"
                
                # Summarize the file and append to the summary file while displaying to terminal
                ollama run vanilj/phi-4 "Summarize:" < "$file" | tee -a "$main_dir/$summary_file"
                echo "$file_path" >> "$main_dir/$progress_file"
            fi
        fi
    done
}

# Recursively process subdirectories
process_subdirectories() {
    for dir in "$1"/*/; do
        if [ -d "$dir" ]; then
            process_files "$dir"  # Process files in the subdirectory
            process_subdirectories "$dir"  # Recursive call for further subdirectories
        fi
    done
}

# Main execution
process_files "$main_dir"  # Process files in the main directory
process_subdirectories "$main_dir"  # Process files in subdirectories

echo "Holistic summarization process completed at $(date)" >> "$main_dir/$progress_file"
EOF`n
)
return

;; Changed files ;;

::whatnames::git diff --name-only HEAD~1 HEAD

::whatdiff::git diff --name-only main..volsorium

::whichl::cat /etc/os-release

::wslhome::\\wsl.localhost\Ubuntu\home\flyxion

::ragdata::C:\Users\nateg\AppData\Local\NVIDIA\ChatWithRTX\RAG\trt-llm-rag-windows-main\dataset
::embedings::C:/Users/nateg/OneDrive/Documentos/Github/academizer_vector_embedding

::get perma::git clone https://git.bleu255.com/repos/permacomputing.git

; Toggle desktop icons visibility
; Using Ctrl+Alt+D as the hotkey

; Toggle desktop icons visibility
; Using Ctrl+Alt+D as the hotkey

DesktopIcons( Show:=-1 )                  ; By SKAN for ahk/ah2
{
    ; Identify the desktop window
    Local hProgman := WinExist("ahk_class WorkerW", "FolderView") ? WinExist()
    :  WinExist("ahk_class Progman", "FolderView")

    ; Get the handle for ShellDefView and SysListView windows
    Local hShellDefView := DllCall("user32.dll\GetWindow", "ptr",hProgman,      "int",5, "ptr")
    Local hSysListView  := DllCall("user32.dll\GetWindow", "ptr",hShellDefView, "int",5, "ptr")

    ; Check if the SysListView window is visible and toggle visibility
    If ( DllCall("user32.dll\IsWindowVisible", "ptr",hSysListView) != Show )
        DllCall("user32.dll\SendMessage", "ptr",hShellDefView, "ptr",0x111, "ptr",0x7402, "ptr",0)
}

^!d::DesktopIcons()

;; frame reducer ;;

::foreshorten::ffmpeg -i peripatetic.mp4 -vf crop=in_w:in_h-20, pdecimate,setpts=N/FRAME_RATE/TB patetic.mp4 

::convertt::ffmpeg -i peripatetic.mkv -codec copy peripatetic.mp4

::clipp::ffmpeg -i patetic.mp4 -t 30 -c:v copy -c:a copy peripatetitic-walking.mp4


;; Shutdown windows in 10 minutes ;;

::in10::Shutdown -s -t 600


::whichtorch::python -c "import torch; print(torch.__version__)"

::gettransformers::pip install git+https://github.com/huggingface/transformers

::getgh::
(
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
)
return

::signin::gh auth login

::whatdiverse::What does the phrase diverse intelligence mean?

;; remap calculator key  to backspace;;

SC121::BS

;; frame reducer ;;

::foreshorten::ffmpeg -i peripatetic.mp4 -vf crop=in_w:in_h-20, pdecimate,setpts=N/FRAME_RATE/TB patetic.mp4 

;; no quotes, ls without quotes, from https://unix.stackexchange.com/questions/258679/why-is-ls-suddenly-wrapping-items-with-spaces-in-single-quotes;;

::noq::ls() {`n# only way I can stop ls from escaping with backslashes`n    if [ -t 1 ]; then`n/bin/ls -C $@ |cat`n    else`n/bin/ls $@ |cat`n    fi`n}


::todec::let i=1 | while i<=18000 | execute 'normal! i' . printf("fr/fr_%05d.mp3", printf("%d", i)) | let i+=1 | endwhile



::convertt::ffmpeg -i peripatetic.mkv -codec copy peripatetic.mp4

::clipp::ffmpeg -i patetic.mp4 -t 30 -c:v copy -c:a copy peripatetitic-walking.mp4



::nullwave::What is the purpose of a null-wavefront in Null Convention Logic?



;; Shutdown windows in 10 minutes ;;

::in10::Shutdown -s -t 600

/*
;; image editor - IrfanView;;

;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv
SetBatchLines -1

; Variables

number := 0.0


; Hotkey
*z::
SetFormat, float, 03.0
number += 1.0
Send % number
Return

*a::
number := 148.0
Return

*v::
Send ^y
Return 

;;;;;;;;;;;;;;;;;;;;;;;;
*/

;; disable mouse (block mouse);;

; This script toggles mouse movement on and off using Alt + H
; Shows a tray tip when mouse movement is disabled
; Press ESC to disable mouse movement if it's currently enabled

#Persistent  ; Keeps the script running

; Toggle variable
toggle := 0

; Alt+B hotkey
!b:: 
toggle := !toggle  ; Switches the value of toggle between 0 and 1
if (toggle = 1) {
BlockInput MouseMove  ; Disable mouse movement
TrayTip, Mouse disabled, Press [ESC] to enable mouse movement
} else {
BlockInput MouseMoveOff  ; Enable mouse movement
}
return

; ESC hotkey
~Esc:: 
if (toggle = 1) {
BlockInput MouseMoveOff  ; Enable mouse movement
toggle := 0
TrayTip, Mouse enabled
}
return

;; youtube downloader

::getvid::yt-dlp https://www.youtube.com/watch?v=-G903FiNE80 -o output.mp4

;; silence ;;

:*:shh::[[slnc 1000]]

;; vim ;;

::noblink::set guicursor=a:blinkon0
::notools::set guioptions-=T
::nomenu::set guioptions-=m
::bluee::sima Eo{Down}
::hidec::highlight Cursor guifg=white guibg=blue

::noda::%s/—/--/g
::nol::%s/“/"/g
::nori::%s/”/"/g 

::nonul::vim -c '%s/null-wavefront.txt/input.txt/g' -c 'wq' speech-test.py

::nowrap::set nowrapscan
::yeswrap::set wrapscan

::fontss::C:\USERS\MECHACHLEOPTERYX\APPDATA\LOCAL\MICROSOFT\WINDOWS\FONTS\

::setfont::edge://settings/fonts



::myfonts::C:\Users\Mechachleopteryx\AppData\Local\Microsoft\Windows\Fonts

::todec::let i=1 | while i<=18000 | execute 'normal! i' . printf("fr/fr_%05d.mp3", printf("%d", i)) | let i+=1 | endwhile

;; Arabic tests ;;

::arabicgreeting::say -v Majed "مرحبًا، اسمي ليلى. أنا صوتٌ عربي."

::arabichello::say -v Majed "السلامة"

::arabicteacher::say -v Majed "أحب الكاتبة، وهي تعمل في المدرسة."

::arabicfont::SimSun-Ext B
;; vim convert to unicode ;;

:*:utff::set fileencoding=utf8

::shellsheck::shellcheck
:*:shelll::shellcheck

;; sudoku game ;; swap add (+)
;; and numlock on numpad

toggle := false  ; Initialize the toggle variable

; Check state of toggle and remap NumpadAdd accordingly
#If (toggle)
NumpadAdd::NumLock
#If

; Toggle the functionality with NumLock
NumLock::
toggle := !toggle  ; Toggle the state
if (toggle)
SetNumLockState, AlwaysOff  ; Optionally, ensure NumLock is off when remapping is active
else
SetNumLockState, AlwaysOn   ; Optionally, ensure NumLock is on when remapping is inactive
return


;; windows zed -> printscreen ;; ctrl windows zed - select printscreen
#z::Send, #{Vk2CSc137}
^#z::Send, {Vk2CSc137}

;; gpt ;;

:*:afaf::
(
A list of everything we've talked about so far.`n
)
return

::whatp::
(
What is the purpose of a propagating null wave front in Null Convention Logic?
)
return

::nonew::
(
for file in new_*.png; do mv "$file" "${file/new_/}"; done
)

::cropall::mogrify - crop 1080x1985+0+360 *.jpg

::ocrall::for file in *.pdf; do ocrmypdf "$file" "${file%.pdf}-ocr.pdf"; done

::getghost::sudo apt update && sudo apt install ghostscript -y

::compressgif::convert animated.gif -fuzz 5% -layers Optimize -colors 64 -delay 20 -loop 0 compressed_animated.gif

::invrt::mogrify -negate *.png

::darkmode::
(
for file in *.png; do
convert "$file" -fill "#0D1019" -draw "color 0,0 replace" "new_$file"
done
)

!S::Send, Summarize:
:*:afs::A final summary.`n
:*:cbt::Connections between the topics.`n

::tchat::sudo docker run -it lwe_llm-workflow-engine /bin/bash

::gptchat::chatgpt
::ccc::chatgpt

:*:tnt::A summary of the themes and topics of this conversation.`n

::resu::Un resumen de los temas y tópicos de esta conversación.

/*
;; dinkus ;;

:*:zzz::`n`n* * *`n`n
*/
::whats::chatgpt what is
::hh::chatgpt

!e::
Loop 10,
{
Send, !q
Sleep, 2000
Send, `n
}

;; TODO December 2022;;
/*
Make above function interruptable
maybe !r to stop

You can use Break and a variable to totally Terminate a Loop when you press a hotkey (or when something else changes the variable):

stop = 0
Loop
{
  If stop = 1
      Break
  ToolTip, %A_Index%
  Sleep, 500
}

^q::
If stop = 0
  {
   stop = 1
   return
  }
If stop = 1
  {
    stop = 0
    return
  }

from https://www.autohotkey.com/board/topic/5991-how-to-interrupt-ahk-loop/

*/


;; cognate cognatesh cognac cognacsh ;;

::runall::for FILE in *; do cognac $FILE -run ; done

=======
;; Github

::reflogg::git reflog

::getdetails::git reflog --format='%H' | xargs -L 1 git log -n 1

=======

=======

::latest!::git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

/*
;; forth forthsh ;;

:*:+0::0


::ghistory::vim ~/.gforth-history

;; generate random ;;

::gr::
(
VARIABLE (RND)
2463534242 (rnd) ! \ seed

: rnd ( -- n ) (rnd) @ dup 13 lshift xor dup 17 rshift xor dup dup 5 lshift xor (rnd) ! ;
)


::basicc::vintbas

;; ok? ok?sh ok oksh ;;

/*

::add ok::alias ok="go run ~/projects/OK/ok/main.go"


;; unchanged
;; a >= b a >= b

::refresher::a >= b, a <= b, a > b, a < b, a == b, a != b

;; fixer upper ;;
:*:a <= b::b >= a
:*:a > b::!(b >= a)
:*:a < b::!(a >= b)
:*:a == b::let x = a >= b; let y = b >= a; x && y
:*:a != b::let x = !(a >= b); let y = !(b >= a); x || y

*/

;; windows tricks ;;
::blam::for i in {1..5}; do touch file$((i)); done
::blip::for i in {1..100}; do touch file$((i)); done
::blop::for i in {1..1000}; do touch file$((i)); done

/*
;; temporary please deactivate immediately after use ;;

::no::rm *
*/

;; Mouse clicks

;; Send a right click

#c::Click, left

;; cut / paste in powershell terminal

#v::Click, right

/*
;; Code to write code: Autohotkey script. ;; best command ever - alt-bash (alt-b)  <newline> !b::Send, {!}{!}bash`n ;; 
;; best command ever (control-b or alt-b)
*/

;; For more information, see: 
;; Beginner Boost, Day 37: Prefer Shell Scripts Over Plugins in Vim [20210706230535]
;; https://youtube.com/clip/Ugkxbqw7ZVfcBAxm8bG81oi3A5BdnDqmw0Py

::instal::install

;; for vim ;;

/*
;^b::Send, {!}{!}bash`n
!b::Send, {!}{!}bash`n
*/

;; from insert mode
:*:ruun::
Send, {Esc}
Send, {!}{!}bash`n
Return


;; fix linefeeds ;;
::no^m::sudo sed -i -e 's/\r$//'

;; womb matrix mind ;; what i want to think about ;; i will "accidentally" stumble
;; upon more ;; write it on the doorposts ;; theory of loose parts ;;

;; math mathsh ;;

;; odd square numbers or centered octogonal numbers ;;
::oddsquare::function square { for i in {1..200000}; do echo $(( ($i*2 +1) **2 )); done; }


;; prolog prologsh ;;

::searchpath::findall([X,Y],file_search_path(X,Y),Bag).

:o:az::assertz
:o:ra::retractall

::goo::vim mortal.pl

::ismortal::
(
man(socrates).
mortal(X) :- man(X).
)

::soo::

::welll::mortal(socrates).


::hw::write('Hello, World'),nl,write('Welcome to Prolog'),nl.
::stat::statistics.

;; maybe extremely inconvenient maybesh maybsh ;;
:*:maybee::Contiguous Rolling Context Mixed Initiative Dialog 

;; repeat after me book (ramb) ;; ramb sonnet ;; rambsh ;;

::mayb::Contiguous Rolling Context Mixed Initiative Dialog
::ramb::Contiguous Rolling Context Mixed Initiative Dialog
::rmb::Contiguous Rolling Context Mixed Initiative Dialog
::crc::Contiguous Rolling Context Mixed Initiative Dialog
::mixd::Contiguous Rolling Context Mixed Initiative Dialog
::minx::Contiguous Rolling Context Mixed Initiative Dialog
::mxnd::Contiguous Rolling Context Mixed Initiative Dialog
::mxid::Contiguous Rolling Context Mixed Initiative Dialog
::noo::Contiguous Rolling Context Mixed Initiative Dialog
::corc::Contiguous Rolling Context Mixed Initiative Dialog
::conc::Contiguous Rolling Context Mixed Initiative Dialog
::crd::Contiguous Rolling Context Mixed Initiative Dialog
::croll::Contiguous Rolling Context Mixed Initiative Dialog

;; not a counter countersh ;;

:*:....::(1,2,3,4,5)

::allowmixed::git config --global core.autocrlf false

;; gimp ;; gimpsh ;;

::getgimp::sudo apt-get install gimp


;; speed  speedsh ;;
::fasle::false
::INt::int

;; this is annoying
/*
NumpadEnter::Send, Bullshit

;; forth newline ;;
NumpadEnter::Send, cr . cr {Enter}

;; 
*/

;;test;; cr . cr 


;; workspace ;;

;; ::workspace::

::lg::ls | grep

::logick::coqtop

;; authentication
!o::
Send {F7}
Send ? ssh-`n
Send {Space}
Send `$
Return


::fixssh::ssh-keyscan -H 192.168.2.233 >> /c/Users/Mechachleopteryx/.ssh/known_hosts

;; enxrypt ;; myaliases ;; sga aliases aliash

::getmy::
(
alias ='cd'
alias ='less'
alias ='ls'
alias ='mkdir'
alias ='echo $(moontop)'    
alias ='touch'   
alias ='vim'
alias ='alias'
 ='rm'
 ='cat'`n
)

::concho::
(
aliases['']='alias'
aliases['']='cd'
aliases['']='less'
aliases['']='ls'
aliases['']='mkdir'
aliases['']='echo $(moontop)'    
aliases['']='touch'
aliases['']='exit'
aliases['']='vim'`n
)


::concha::
(
$PROMPT_FIELDS['me'] = "{FAINT_GREEN}"
$PROMPT_FIELDS['g'] = "{INTENSE_GREEN}"
$PROMPT = "{me}{user}{g}@{hostname}{me}{cwd}> "`n
)


::dockrun::sudo docker run -ip 127.0.0.1:3000:3000 mechachleopteryx/devenv

;; hide ip addresses ;;

::hideip::
(
sed -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/###.###.###.###/g' -i
)
return 

;; ahk experiments ;;

;; ConsoleWindowClass ;; open wsl terminal
;; type cwc space, or alt + w 

  ;; eXecute
  ; :X:mib::MsgBox  ;; just accidentally triggered this 2022-04-24

:X:cwc::run, C:\Windows\System32\wsl.exe, C:\Windows\System32  ;; let's see what happens
!w::run, C:\Windows\System32\wsl.exe, C:\Windows\System32  ;; let's see what happens


; :*:testtttttttttttttttttttttttt::testtttttttttttttttttttttttt    w  o   r   k  i   n  g  !!   tttttttttttttttttt
; ::test?::working!  



::mereo::
(
Ocularomonoturnolamphrolamphrodyno
gravitoquarko electrolepto
fermiophoto gluomeso
bosoproto neutrobaryo
hadroato moleculounicellulo
crystolattisso micro megalobio gaiama
techniotella gaiaselena solara
perinebula vacuo oriocygnobrachio galacto
proximasystada virgo laniakeasuperclusto piscescetusfilamentocytosis
)


;; em dash ;;
::---::—

::getpip::sudo apt install python3-pip

::getgpt::pip install git+https://github.com/llm-workflow-engine/llm-workflow-engine

;; xonsh ;; xonshs ;; xonshsh ;; python-like shell

:*:lm::lambda
:*:l;::λ

;; control-c to advance to the next image

;; my cool program

::loook::
(
for file in gp``*.*``:
    if file.exists():
        display @(file)`n`n    
)

::echolo::echo "hello" | @(lambda a, s=None: s.read().strip() + " world\n")
::makesome::for i in range(20):`n$[touch @('file%02d' % i)]`n`n
::helloworlds::eg = 'hello'; echo path/to/@(['hello', 'world]'])
::dosomething::echo @(['a', 'b']):@('x', 'y')
::border of the absurd::$[@$(which @($(echo ls).strip())) @('-' + $(printf 'l'))] ;; long listing


;; asahi -- asahish ;;

::new mirror::curl -s "https://archlinux.org/mirrorlist/?country=FR&country=GB&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -

;; batch loop for bash ;;

::forsay::for i in {00..99} `;do say -o supersition$i.aiff -f x$i`;done

::fordo::for i in {00..99} `;do lame -m m supersition$i.aiff superstition$i.mp3 `; done



::superpac::sudo pacman -Syu

;; linux -- linuxsh;;

::gimme::for i in ``seq 1 10``; do   let result="$RANDOM % 300 + 200";   echo "A number: $result"; done

::addme::adduser -m flyxion
::undome::userdel -r flyxion

::gita::git config --global user.name "standardgalactic"
::gitb::git config --global user.email "standardgalactic@protonmail.com"

::goto::git checkout main
::re set::git reset --hard 0478f98189ae613b533f4e4829799354549353e9
::do ne::git push --force origin main


;;lynxspace;;

::gtt::sudo apt-get install
::upd::sudo apt-get update
::upg::sudo apt-get upgrade
::updg::sudo apt-get dist-upgrade

;; llast ;; last loop(?) ;; exit status ;; did it work?  -- 0 indicates success; 1 +, failure
::lastcommand::echo $?`n

::s a::{,,,,,,,,,,,,,,,,,,,,,,,,,}

; a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
; ,,,,,,,,,,,,,,,,,,,,,,,,,

::2sga::a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z = symbols(',,,,,,,,,,,,,,,,,,,,,,,,,')

;; bash bashsh ;;

::lasthour::find . -mmin -60 -print -exec tail -n 2 \{\} \;

;; remove by node (inode) ;;
::rmbyn::find . -inum 524769 -exec rm -i {} \;

::blox::lsblk

::start ssh::sudo systemctl start sshd
::startssh::/etc/init.d/ssh start

::konfig::tmux new-session -d 'vi ~/.tmux.conf' \; split-window -d \; attach

;; install docker ;;

;; elm elmsh ;;
::?elm::# get, unzip, bop, move

;; install elm ;; 
::getit::curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
::unzipit::gunzip elm.gz
;; bopit
::moveit::sudo mv elm /usr/local/bin



::getsteps::# getup, getready, getkey, getrepo, getup (again), getdocker



::getup::apt-get update
::getready::apt-get install ca-certificates curl gnupg lsb-release
::getkey::curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
::getrepo::echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
::getdocker::apt-get install docker-ce docker-ce-cli containerd.io

::didntwork::curl -fsSL test.docker.com -o get-docker.sh && sh get-docker.sh


;; update node.js ;;
::nodesteps::# update node; clearcache, andthen, andthenn
::clearcache::sudo npm cache clean -f
::andthen::sudo npm install -g n
::andthenn::sudo n latest

;; install julia ;;
::getwget::apt install wget -y
::getjulia::wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz
::untar::tar xvf julia-1.7.2
::whatnext::#sudo mv julia-version to /opt/julia , add "juliapath" to "bashrc" and then "sourcemy"
::juliapath::export PATH=$PATH:/opt/julia/bin

::archjulia::wget https://julialang-s3.julialang.org/bin/linux/aarch64/1.6/julia-1.6.0-linux-aarch64.tar.gz

;; unison language ;; unisonsh ;;

::howtu::# mu, getu, untu, gu


::mku::mkdir unisonlanguage

::getu::curl -L https://github.com/unisonweb/unison/releases/download/release%2FM3/ucm-linux.tar.gz --output unisonlanguage/ucm.tar.gz
::untu::tar -xzf unisonlanguage/ucm.tar.gz -C unisonlanguage
::gu::./unisonlanguage/ucm


;; installing ubuntu on termux

/*
::instructshions::
(
Update termux: apt-get update && apt-get upgrade -y
Install wget:: apt-get install wget -y
Install proot:: apt-get install proot -y
Install git:: apt-get install git -y
Go to HOME folder: cd ~
Download script: git clone https://github.com/MFDGaming/ubuntu-in-termux.git
Go to script folder: cd ubuntu-in-termux
Give execution permission: chmod +x ubuntu.sh
Run the script: ./ubuntu.sh -y
Now just start ubuntu: ./startubuntu.sh
)
*/

;; ubuntu in termux ;;

::get termux::git clone https://github.com/MFDGaming/ubuntu-in-termux.git

::into bashrc::>> ~/.bashrc

::rn::rename 's/$/\.tsv/' *

::pastebin::cat "filename" | curl -F 'f:1=<-' ix.io
:o:getback::curl http://ix.io/
::getix::curl http://ix.io/2F1r > /tmp/ix
::moveit::sudo mv /tmp/ix /bin
::bopit::sudo chmod +x

;; ls with most recent last ;;
::ls now::ls -latr

::inv::ls -1 | wc -l

::noext::ls -1 | sed 's/\.[^.]*$//'

::usevi::sudo echo "export EDITOR=vim" >> ~/.bashrc

::add2bash::sudo echo "export PATH=$PATH:$(pwd)" >> ~/.bashrc
::add2path::export PATH=$PATH:$(pwd)

;; workspace ;;
::wrk::cd /home/Lynxspace/.local/bin/scripts/



::ubunturoot::ubuntu config --default-user root  ;;from powershell
::bitcoinprice:: curl -s --location --request GET https://api.coinstats.app/public/v1/coins/bitcoin\?currency\=USD


::mynumber::cat /etc/issue
::upgrayde::sudo apt-get update && sudo apt-get dist-upgrade
::grock::grep -ri -C 10 "docker" .
::vr::vim README.md
::reme::README.md

;; google cloud gcd ;;

::ver tex::
(
pip install virtualenv
virtualenv memex
source memex/bin/activate
memex/bin/pip install google-cloud-aiplatform
)
return

::runn::http://ix.io/4M34

::loginn:: gcloud auth application-default login

::setquota::gcloud auth application-default set-quota-project archeopteryx

;; chromesh ;;

::installchrome::wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;sudo apt install ./google-chrome-stable_current_amd64.deb

::polly::sudo su - pollinate -s /bin/bash
::showpath::echo -e ${PATH//:/'\n'}
::lookhere::export PATH=".:$PATH"

::geekstuff::echo "Welcome To The Geek Stuff" | sed 's/\(\b[A-Z]\)/\(\1\)/g'
::randoms::for i in ``seq 50``; do echo $RANDOM; done
::snorttd::ls /bin /usr/bin | sort | uniq -d | less
::snortt::ls /bin /usr/bin | sort | uniq | less


:*:@k::㉿ ;; sends a double tab in kali linux
::eqwals::====================================

:*:gitt::cd ../OneDrive/Documents/GitHub/

:*:sloooooooooo::pv -q -L 30 < overview.txt

/*
!k::Send,㉿ ;; sends a double tab in kali linux
return
^k::Send,kubectl ;; sends a double tab in kali linux
return
*/

;------------------------------------------------------------------------------
; Control + Home Row for Arrow Keys
;------------------------------------------------------------------------------
^h::Send, {Left}       ; Ctrl + H -> Left Arrow
^j::Send, {Down}       ; Ctrl + J -> Down Arrow
^k::Send, {Up}         ; Ctrl + K -> Up Arrow
^l::Send, {Right}      ; Ctrl + L -> Right Arrow
^;::Send, {Enter}      ; Ctrl + ; -> Enter
 
;------------------------------------------------------------------------------
; Alt + Home Row for Special Functions
;------------------------------------------------------------------------------
!h::Send, {Backspace}  ; Alt + H -> Backspace
!j::Send, {Enter}      ; Alt + J -> Enter
!k::Send, {Enter}      ; Alt + K -> Enter
!l::Send, {Space}      ; Alt + L -> Space


;; run "vim bashrc" before and "sourcemy" afterward ;;

::noemacs::
(
set -o vi
export EDITOR=vim
export VISUAL=vim
)
return

::emacs sucks::set -o vi

::no emacs::set -o vi
::vimplease::set -o vi
::vim please::set -o vi
::vi please::set -o vi
::viplease::set -o vi
::setvi::set -o vi

::emacs please::set -o emacs
::emacsplease::set -o emacs

;; repeat last command ;;

::rpt::
(
while true; do !! `n
sleep 5 `n
done `n
)
return


::pls::sudo !!
::huh:: man !!


;; System and Environment Configuration ;;

::texty::curl txti.es/5rif8 > texty-test

; Fetches content from a specified URL and saves it to a file named 'texty-test'.

::swapmy::echo '/usr/bin/setxkbmap -option "caps:swapescape"' >> ~/.bashrc

; Appends a command to the end of the .bashrc file to swap the Caps Lock key with the Escape key.

::ee::export EDITOR=vi

; Sets the default editor to vi for command-line operations.

::sourcemy::exec bash -l

::sm::exec bash -l

; Reloads the bash shell, executing as a login shell.

::bashrc::~/.bashrc

; Opens the .bashrc file for editing.

::editmy::vim ~/.bashrc

; Opens the .bashrc file for editing in Vim.

;; Vim Specific ;;

::myvim::e $MYVIMRC

; Opens the Vim configuration file for editing.

::source ~::source $MYVIMRC

; Sources (reloads) the Vim configuration file.

;; System Queries and Operations ;;

::checkpack::ls /bin/b* | xargs /usr/bin/dpkg-query -S

; Lists packages associated with executables in /bin that start with 'b'.

::what load::watch `cat /proc/loadavg`

; Continuously displays the system load average.

::dunno::diff <(ls LearnVim) <(ls Learn-Vim)

; Compares the contents of two directories.

::howmanyseconds::echo There are $((60*60*24*365)) seconds in a non-leap year

; Calculates and displays the number of seconds in a non-leap year.

;; Software Installation and Configuration ;;

::preinstall::sudo apt-get install build-essential libatomic1 python gfortran perl wget m4 cmake pkg-config curl

; Installs various development tools and libraries.

::myjulia::cd ~; git clone https://github.com/JuliaLang/julia

; Clones the Julia programming language repository into the home directory.

::certifyme::sudo apt install ca-certificates

; Installs the CA certificates package.

::autorm::sudo apt autoremove

; Removes unnecessary packages from the system.

::sudoer::sudo usermod -aG sudo

; Adds the current user to the sudo group.

::kalilinux::sudo docker start -i vigorous_morse
::/kali::sudo docker start -i vigorous_morse

; Starts a Kali Linux Docker container.

;; User Aliases ;;

::lnx::su Lynxspace

; Switches the current user to 'Lynxspace'.

::llrr::alias r=R
::littler::alias r=R
; Sets an alias 'r' for 'R' in the shell.

;; Linux Demo - uncomment to activate ;;

;; ::wow::cowsay "I can't believe that actually worked."

; When activated, this hotstring will execute the 'cowsay' command with a specified message in a Linux terminal. 'cowsay' is a program that generates ASCII pictures of a cow with a message.


;; Spanish Punctuation ;;

; Sets up hotstrings for typing the inverted question mark.

:*:/?::¿
:*:^?::¿
:*:?``::¿


; Sets up hotstrings for typing the inverted exclamation mark.

:*:/!::¡
:*:^!::¡
:*:!``::¡


; Sets up hotstrings for typing accented vowels and 'ü'.

:*:a``::á
:*:e``::é
:*:i``::í
:*:o``::ó
:*:u``::ú
:*::u::ü

; Sets up hotstrings for typing the 'ñ' character.

:*:n``::ñ
:*:n~::ñ


;; audiobook ; audiobooks

::doit::say -o monicaspills.aiff -f mpills.txt
::thenn::lame -m m monicaspills.aiff pills.mp3

::supersplit::awk '{print > ("output/en_" sprintf("%05d.txt", NR)); close("output/en_" sprintf("%05d.txt", NR))}' english.txt

::foreach::for file in * `; do say -o "${file%.*}.aiff" -f "$file"`; done

::tomp3::for file in * `; do lame -m m ${file%.*}.aiff ${file%.*}.mp3 `; done

::sewit::ffmpeg -f concat -i list.txt -c copy output.mp3

::slowdown::ffmpeg -i bio-rational.mp3 -filter_complex "asetrate=44100*0.44,atempo=0.88" -q:a 0 bio-relational.mp3

;; microsize video to mp3 ;;

::musize::ffmpeg -i input.mp4 -vn -ab 64k output.mp3

::filelist::
(
touch file_list.txt

for i in {0..18}; do
if (( i % 2 == 0 )); then
echo "file 'even/sphere-$i'" 
else
echo "file 'odd/sphere-$i'"
fi
done
)
return


;;;;;;;;;;;;;jose;;;;;;;;;;;;;;;
;; antihotstrings antihotkeys ;;
;;                            ;;
;;  an oz. of prevention ;;   ;;
;;                            ;;
:*:sudo rm -rf /::No way, José
:*:sudo rm -rf *::No way, José
:*:rm * .::rm *.              ;;
:*:ls > less::ls | less       ;;
;;                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; synonyms ;;

; ::boring::uninteresting
::boring::good


;; sanitizer ;;
:*:fuck::f_ck
:*:fsck::What the fuck are you trying to do? ;; WARNING!!!  The filesystem is mounted.   If you continue you ***WILL*** cause ***SEVERE*** filesystem damage.

Searching()
{
	imagesearch, FoundX, FoundY, 0, 0, 4000, 1500, *5 C:\Path\ C:\Users\Mechachleopteryx\OneDrive\Pictures\baclk.png
		if errorlevel = 0 
		{
		mouseclick, left, %FoundX%, %FoundY%
		}
		else
		{
		imagesearch, FoundX, FoundY, 0, 0, 4000, 1500, *5 C:\Path\Image2.png
			if errorlevel = 0 
			{
			mouseclick, left, %FoundX%, %FoundY%
			}
			else
			{
			imagesearch, FoundX, FoundY, 0, 0, 4000, 1500, *5 C:\Path\Image3.png
				if errorlevel = 0 
				{
				mouseclick, left, %FoundX%, %FoundY%
				}
				else
				{
				msgbox, Could not find.
				}
			}
		}
	return
}

;;ImageSearch, FoundX, FoundY, 40, 40, 300, 300, C:\Users\Mechachleopteryx\OneDrive\Pictures\baclk.png

::hackmy::hollywood

;; program ;;
;::ones::       +       +    +=      
::1s::1000 + 100 + 10 + 1  =   1,111

::twos::        +       +      +=   
::2s::2000 + 200 + 20 +  2 = 2,222

::threes::        +       +      + =   
::3s::3000 + 300 + 30 + 3  = 3,333

::tq::The quick brown fox jumps over the lazy dog.

;; program ;;


;;  sga ;;
::sga example::sed 'y/abcdefghijklmnopqrstuvwxyz//' <<< 'The quick brown fox jumps over the lazy dog.'
:o:to-sga::sed 'y/abcdefghijklmnopqrstuvwxyz//' <<< '
:o:from-sga::sed 'y//abcdefghijklmnopqrstuvwxyz/' <<< '

!p::Run, notepad.exe "C:\Users\nateg\OneDrive\Documentos\Github\example\PrintScreen.ahk" ; press Alt+p to open this file. (if OpenShowApps is running
; hit F8 to source this script.) ;; implemented in AutoHotkey-script-Open-Show-Apps.ahk-

;; Starting Task View — tested with Win10
;; same as Windows+Tab

^!l::Run, explorer shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}

; ::newhot::new hotstring ;; test string

;; Instructions. After making changes, save, then
;;run script PrintScreen.ahk in
;;C:\Users\Mechachleopteryx\OneDrive\Desktop\Blank\Examples
;;to put in startup menu, first compile into an executable (.exe)
;;and then place in (startup) folder C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
;; or make a executable script just runs printscreen.ahk;; it hasn't gotten
;; annoying yet, so I haven't tried this. 


:*:
;;  fill form
:o:ff::mechachleopteryx
:o:mm::mechachleopteryx

;; ruby ;; rubysh
::whyle::
(
a = 0
while a < 15
    print a, " "
    if a == 10 then
        print "made it to ten!!"
    end
    a = a + 1
end
print "\n"
)

::breakeggs::
(
joe = [ 'eggs.', 'some', 'break', 'to', 'Have' ]
print(joe.pop, " ") while joe.size > 0
print "\n"
)

;; rust ;; rustsh ;;

::getbuild::sudo apt-get install build-essential

::getrust::sudo curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh


;; docker -- dockersh ;;
::fixdisplay::export DISPLAY=172.17.0.1:0.0

;; openai - openaish ;;

:o:okey::export OPENAI_API_KEY="
::gp::chatgpt

::stor::cd ~/.local/share/chatgpt-wrapper/profiles/default/


;; java javash ;;

:o:syp::System`.out`.println(

:*:jsell::jshell

::kill jshell::kill -9 $(ps -a | grep "jshell" | awk '{print $1}')

::puv::public void
::puf::public final class

::xanadumode::/set mode xanadu normal -command

::setupp::/set prompt xanadu "\nxanadu$ " "   continue$ "
::setfeed::/set feedback xanadu

;; scheme schemesh ;;

::make square::(define (square x) (* x x) )

::sum of squares::
(
(define (sum-of-squares x y)
  (+ (square x) (square y) ) )
)

::f of a::
(
(define (f a)
   (sum-of-squares (+ a 1) (* a 2 )))
)

::define abs::
(
(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
)

::define relu::
(
(define (relu x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) 0)))
)



::how do i install scheme::
(
Installing

Debian or Ubuntu or other derived distros:

sudo apt-get install chicken-bin

Fedora / RHEL / CentOS:

sudo yum install chicken-bin

Arch Linux:

sudo pacman -S chicken

Gentoo:

sudo emerge -av dev-scheme/chicken

OS X with Homebrew:

brew install chicken

OpenBSD

doas pkg_add -vi chicken

Microsoft Windows

     * Install MSYS2
     * Run the MSYS2 MinGW-w64 Shell
     * Install some prerequesites by running:
pacman -S mingw-w64-cross-toolchain base-devel mingw-w64-x86_64-gcc winpty wget

     * Download the latest release tarball by typing:
wget https://code.call-cc.org/releases/current/chicken.tar.gz

     * Extract the tarball by running tar xvf chicken.tar.gz
     * Enter the extracted directory, for example by typing cd chicken-4.11.0
     * Run make PLATFORM=mingw-msys install

   If you have trouble running csi , try instead running winpty csi
)

::chickenn::sudo apt-get install chicken-bin

:*:SEnd::Send

;; clojure clojuresh ;;

::clo::clojure

:*:lode::
Send, load-file " "
Send, {Left 2}
Return


;; bracket (bubble) ;;
^b::
Send, ( )
Send, {Left 2}
Return


;; end clojure ;;

::circ::circumference

::langwages::
(
  1 c    - C
  2 cc   - C++
  3   clj  - Clojure
  4 cs   - C# (mono)
  5   erl  - Erlang
  6   go   - Go
  7 hs   - Haskell (ghc)
  8   java - Java
  9 js   - Javascript (Node)
 10   lua  - Lua
 11   ly   - LilyPond
 12   m    - Objective C
 13 pas  - Pascal (gpc)
 14   php  - PHP
 15   pl   - Perl
 16   py   - Python
 17   rb   - Ruby
 18   rs   - Rust
 19 sh   - Shell (sh)'''
)
;; randomsh ;;

:o:neander::Neanderthal

;; Github githubsh ;;

::howmany::gh api users/standardgalactic | jq '.total_private_repos + .public_repos'

::get repos::gh repo list --limit 18000 > repo-list




:o:gitname::standardgalactic
:o:git name::standardgalactic
:o:sg::standardgalactic

:o:ppff::Playfloor
:o:mt::mysterytrader

::hap::haplopraxis

:o:gala::Galactromeda
:o:phf::phewf

:o:listmy::# sg, pf, gala, mt, s11e, hap, ph
:o:listmyfull::# standardgalactic, Playfloor, Galactromeda, mysterytrader, strategyguide, phewf

::pps::import pioupiou as pp

::dri::docker imager rm
::dockter::docker
::decer::docker
::dcr::docker
::dockr::docker
:r:dcker::docker
::dckr::docker
::dkr::docker
::dkcr::docker
::cdrk::docker
::oderck::docker
::odcker::docker ;; daw (dcoekr) ker
::dcoekr::docker ;; daw (dco) ker
::dcoker::docker ;;
::dawker::docker
::dawcker::docker
::doc ker::docker
::dcork::docker
::cdoer::docker

;; dcoekr ;; dcoker ;; cdoer

;; byobu ;;
::bseta::byobu-ctrl-a


::byo::byobu
::bya::byobu attach

::ubu::ubuntu


;; powershell ;;
::ignorepaste::set $global:multiLinePasteWarning=false,;; don't think this works


;; dosbox ;; Don't use elsewhere, should put a IfWinActive


::mountcd::MOUNT F F:\ -t cdrom

:*B:dvork::
Sleep 100
Send, {bs 1}
Sleep 100
Send, KEYB
Sleep 100
Send,{Space}
Sleep 100
Send, dv103
Sleep 100
Send, {Enter}
Return

;; In vim
:o:findip::\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}

;; Blender shortcuts ;; If WinActive("Blender") don't know/remember how to do this
;:*:cd::
;Sleep, 3
;Send, os.chdir()
;Return

;:*:mkdir::
;Sleep, 2
;Send, os.mkdir()
;Return

;;command line;;
::nodir::
Send, doskey ls=dir $*
Send, {Enter}
Send, doskey pwd=cd $*
Send, {Enter}
Return

;::test::12345789 bytes free

;; windows windowsh windowssh;;


::go2sleep::rundll32.exe powrprof.dll, SetSuspendState Sleep

::tempfolder::C:\Users\Mechachleopteryx\AppData\Local\Temp
::r&r::doskey r=R $*

;; disable windows key ;;
;; LWin:: return
;; RWin:: return

;; disable windows key but not shortcuts ;;
;$lwin up::return
;$rwin up::return
;lwin & r::send #r
;rwin & r::send #r

::wist::wikipedia is toxic
::wint::wikipedia isn't toxic

;this is such 
;a::  ;; press a to start
;bad
;idea
;Loop,
;{
;Send, #n
;Sleep, 100
;}

;; mac shortcuts -- macsh ;;

;; superupdate ;;
::useforce::softwareupdate --all --install --force

;; voices ;; voicesh ;; voicessh ;;

::testvoices::say -v '?' | awk '{print $1}' | while read voice; do printf "using $voice...\n"; say -v $voice "hello, this is me using the $voice voice"; sleep 1; done

::slimvoices::say -v '?' | awk '{print $1}' | while read voice; do printf "using $voice...\n"; say -v $voice " Hi, my name is   Slim Shady"; sleep 1; done

::hellolee::say -v Lee '''Definitions are perhaps the most important component of ontologies, since it is through definitions that an ontology draws its ability to support consistent use across multiple communities and disciplines, and to support computational reasoning. Definitions also constrain the organization of the ontology. Simply put, every term in an ontology (with the exception of some very general terms) must be provided with a definition, and the definition should be formulated through the specification of how the instances of the universal represented by the relevant term are differentiated from other instances of the universal designated by its parent term.'''

::demobile::for file in *.mhtml; do mv "$file" "${file%.mhtml}.txt"; done



::ask me something::/Users/mecha/age_check
::askme::/Users/mecha/age_check

;; Pluto ;;
::powlevel::@bind power_level html"<input type='range'>"

;; concatenate pdf ;;

::howtopdf::step1, step2

::step1::convert *.jpg -auto-orient octoplect.pdf
::step2::ocrmypdf octoplect.pdf octoplexis.pdf

;; docker ;;


::oldworkspace::sudo docker start -i clever_bouman

::rwx::
{
Send, sudo docker start -i quantum_soup ;; confident_euler
Return
}

::4keeps::git clone https://github.com/perkeep/perkeep.git perkeep.org
::getjs::go get github.com/go-goodies/go_jsoncfg

::getsand::git clone http://github.com/niemeyer/hsandbox.git
::pleese::sudo chmod +x hsandbox
::g0::./hsandbox go -c

::xyloid::sudo docker start -i suspicious_shirley

::busybox::sudo docker start -i silly_lederberg  ;; on aarch64

::keenx::sudo docker start -i keen_hawking

::gore please::sudo docker start -i compassionate_swanson ;; go repl, gore ;; human only
::lite::sudo docker start -i cranky_rosalind ;; alpine
::paralite::sudo docker start -i naughty_euclid ;; parabola

::rwxsetup::sudo docker run -it rwxrob/workspace /bin/bash

::archlinux::sudo docker start -i confident_mirzakhani
::archbtw::sudo docker start -i confident_mirzakhani

::qwer::docker start -i kind_boyd
::hask::docker start -i kind_boyd

::inspectr::sudo docker inspect -f "{{ .NetworkSettings.IPAddress }}" confident_euler

;;background change;;
#n::  
try if ((pDesktopWallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}"))) {
	DllCall(NumGet(NumGet(pDesktopWallpaper+0)+16*A_PtrSize), "Ptr", pDesktopWallpaper, "Ptr", 0, "UInt", 0) ; IDesktopWallpaper::AdvanceSlideshow - https://msdn.microsoft.com/en-us/library/windows/desktop/hh706947(v=vs.85).aspx
	ObjRelease(pDesktopWallpaper)
} 
return

;; mistral ai ;;

::mistralplugin::pip install git+https://github.com/llm-workflow-engine/lwe-plugin-provider-chat-mistralai

::getcloud::!pip install --upgrade google-cloud-aiplatform


;; reminder ;;

;; edit vim macro macrosh ;;

; first type : (colon) to enter ex command mode
::&last::
Send, let @q='
Send, ^{r} ;; {Cntrl} Never put control inside curly brackets ({ }).
Send, ^{r}
Send, q
Return  ;; now you have to edit and hit enter.

;; fake bandnames ;;

::cloth mother::C̷̣̝̲̜̈́ͅL͍͚̝͖̭͖̄̍̏O̦̝̬͛̍͗̓͌̊̏T̻͎̬̫̰̭̬̿H̸͎̥̘̘̐ ̜̻͖͎͇͒͑̚ͅ M͍̮̰͈͖̑͜O̟̳ͨ͋͋͐T̫̫ͦ̌̒ͮH͛ͤͣ́Ȇ̩̾ͨ̾ͮȐ̥̤̑ͅ‏‏


;; memrise mode ;;
;:*:1::
;Send,1
;Send,{Enter}
;return

;;didn't work


;; golang go gosh ;;

::pk::
(
package main

import `(
        "fmt"
`)

func main() {
}
)


;; vim -- vimsh ;;


::add line numbers::%s/^/\=printf('%-4d', line('.'))

;; move Control-a (increment) to Control-s (C-x to decrement) ;;

::move inc::nnoremap <C-s> <C-a>h

::fixit::%s/L/\//g


::nowrap::set nowrap

::numb::set relativenumber

::sampletext::
(
------
abbcbb
------
deefee
------
ghhihh
------
)

;; vim show linenumbers if the color is too faint ;;

::greyy::highlight LineNr ctermfg=grey

;; upwards - reverse lines ;;
::upw::g/^/m0

::rmga::g/\v^(a|g)/:d  ;; remove lines starting with g or a ; global delete ;
::rm3:::g/\w$/normal $3X
::vimtime::%s/\v(a|d|g)/\=strftime("%c")/
::nofee:::%s/\v(fee)/\=@w/ ;; replace fee with whatever is in register "w

::makebox::!mkdir ~/sandbox
::addpath::set path+=~/sandbox 

;; no page numbers ;;

::npn:::g/^\d\+$/d


::no spaces::%s/^\s*//g
::no blanks::%g/^\s*$/d
::blanksonly::%s!\n\n\n\+!\r\r!g
::nonotes::%s#\[.*]##g 
::nonums::%s#\[\d*\]##g ;; remove [1],[2],[3], etc
::notags::%s#\[\d*\:\d*\:\d*\]##g
::vim in title::ls -l | grep -i vim

::next4::0,4!column -t -s "|" 
::setgui::set guifont=Fira_Mono_for_Powerline:h26  ;;gvim
::changefont::set guifont=*   ;; gvim

::splitt::
(
for file in *.txt; do
  # Extract the base name without the extension
  basename="${file%.*}"
  
  # Create a directory named after the base name
  mkdir -p "$basename"
  
  # Split the file into chunks of 100 lines each
  # and place the output files into the created directory
  split -d -l 100 "$file" "$basename/${basename}_"
done`n
)
return

::re verse::g/^/m 0

::noscroll::set scrolloff=9999
::scrolloff::set scrolloff=9999
::scrollon::set scrolloff=0 ;;seems to work
::turn off mouse::set mouse-=a

;;sample program;;
;; python3 -c 'import os,sys;os.makedirs(sys.argv[1])' /test2/test_3

::mktest::
Send, python3 -c 'import os,sys;os.makedirs(sys.argv[1])' test; cd test;

;;

;;Send, This is the alphabet.
;;Send, ^q
;;Send, The first letters are abc.
;;return

::fixshell::start "" "%PROGRAMFILES%\Git\bin\sh.exe"  --login -i -c "exec julia"

::pyy::python3
::getall::from sympy import *

:*:mkdirs::
Send, python3 -c 'import os,sys;os.makedirs(sys.argv[1])'
Send {Space}
Sleep 1000
Send, !{q}
Sleep 1000
Send, /
Sleep 1000
Send, !{q}
Sleep 1000
Send, /
Sleep 1000
Send, !{q}
Sleep 1000
Send, /
Sleep 500
Send, !{q}
Sleep 500
Send, `n
return

;; awk ;;
::line#::awk '{print FNR "\t" $0}'
::lineno::awk '{printf("%5d : %s\n", NR, $0)}'

;; choice theory / reality therapy;;
::what i'm doing::what I want

;; julia code -- juliash ;;

::gf::gforth


;; mildly annoying, to say the least ;;

/*
:o:ne::nextind
:o:pre::prevind
:o:fi::firstindex
:o:li::lastindex
:o:ei::eachindex
:o:ti::thisind
*/

:*:thisindex::thisind
:*:nextindex::nextind
:*:previndex::prevind
:*:previousindex::prevind


::ordinaryleast::ols = lm(@formula(Y ~ X), t) ;; using GLM (I think)
::allbinary::foreach(s -> Base.isbinaryoperator(Symbol(Char(s))) && print(Char(s)), 0x20:0x2fff)
::addtj::add https://github.com/benlauwens/ThinkJulia.jl
::tj::using ThinkJulia

::remindme::function workspace();atexit() do; run(``$(Base.julia_cmd())``);end;exit();end

;; egsample example examplesh
::eg::example

;;  Julia # recipe
::add jump::add JuMP
::add egg::add GLPK

::activeate::activate . ;; virtual environment
::use jump::using JuMP
::use egg::using GLPK
::makemodel::model = Model(GLPK.Optimizer)
::makevector::@variable(model, x[1:3])
::makeobj::@objective(model, Max, sum(x) - x[2])
::con1::@constraint(model, x[1] + x[2] <= 3)
::con2::@constraint(model, x[2] + x[3] <= 3)
::con3::@constraint(model, x[2] >= 3)
::op!::optimize!(model)
::valu::value.(x)


::runagain::include("stats_experiments.jl")

::rooot::C:\Users\Mechachleopteryx\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\rootfs\root\home
::toshell::eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

;; Autohotkey Scripts
::ahkey::C:\Users\Mechachleopteryx\OneDrive\Desktop\Blank\Examples

;; Bash shortcuts
::listfilenames::ls -l | awk '{print$9}'
::lsfilenames::ls -l | awk '{print$9}'

::suod::sudo
::sdo::su -
::eixt::exit
::xit::exit


::noroot::su notroot

;;Windows shortcuts
::startup::C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
::jprompt::set PROMPT=$P$G How can I help you?` ` 
::rprompt::set PROMPT=$P$G` `

::prodjects::C`:\Users\nateg\OneDrive\Documentos\projects\

::projectz::/mnt/c/Users/nateg/OneDrive/Documentos/projects
::projext::/mnt/c/Users/nateg/projects

::iuf::𝘐𝘵𝘢𝘭𝘪𝘤 𝘜𝘯𝘪𝘤𝘰𝘥𝘦 𝘍𝘰𝘯𝘵
::phoen::𐤐𐤇𐤏𐤍𐤄𐤂𐤉𐤀𐤂𐤉𐤀𐤍

;;Linux shortcuts

; fix pathname

;; example:  C:\Games\RFTS -> /mnt/c/Games/RFTS

^!s:: ; Sets the hotkey to Control+Alt+S
clipboardText := ClipboardAll ; Backup the entire clipboard
ClipWait, 1 ; Wait time for clipboard
if ErrorLevel ; If there's no text in the clipboard, exit
{
MsgBox, Clipboard is empty or not text.
return
}
originalText := Clipboard ; Store clipboard text
modifiedText := StrReplace(originalText, "C:", "/mnt/c") ; Replace C: with /mnt/c
modifiedText := StrReplace(modifiedText, "Z:", "/mnt/z") ; Replace Z: with /mnt/z
modifiedText := StrReplace(modifiedText, "\", "/") ; Replace backslashes with forward slashes
modifiedText := StrReplace(modifiedText, " ", "\ ") ; Escape spaces
modifiedText := StrReplace(modifiedText, "(", "\(") ; Escape parentheses
modifiedText := StrReplace(modifiedText, ")", "\)") ;   "     "
Clipboard := modifiedText ; Replace clipboard content
; MsgBox, Clipboard content replaced.
Click, right
return


::update-container::docker commit quantum_soup mechachleopteryx/workflow-engine:quantum_soup
::to-dockerhub::docker push mechachleopteryx/workflow-engine:quantum_soup


::what hub::docker search mechachleopteryx

::skil::podman run -it --hostname skilstak --name skilstak -v shared://shared ghcr.io/rwxrob/ws-skilstak

::winhome::C:\Users\nateg\OneDrive\Documentos\projects

::abra::cd /mnt/c/Users/nateg/OneDrive/Documentos/GitHub/abraxas`n

:*:cadabra::C:\Users\nateg\OneDrive\Documentos\Github\abraxas`n

::nopass::ssh-copy-id -i ~/.ssh/id_rsa.pub ;;server;;

::whatnow?::echo $PS1
::litrate::PS1="See Colon Backslash Rightarrow "
::cstyle::PS1="C:\> "
::cprompt::set PROMPT=C:\^>
::C:\>::set PROMPT=C:\^>

::macprompt::PS1="%n@%m %1~ %# "

::normal prompt::PS1="\[\e[38;5;202m\]$(byobu_prompt_status)\[\e[38;5;245m\]\u\[\e[00m\]@\[\e[38;5;172m\]\h\[\e[00m\]:\[\e[38;5;5m\]\w\[\e[00m\]$(byobu_prompt_symbol) "
::mac prompt::PS1="%F{yellow}%n@%F{blue}%m %1~ %#"

::weird prompt::PS1="It is recommended not to use a '>' in your PS1 Command Prompt as if copy/pasted by accident that can cause a redirection and file overwrite. "

::howto::curl https://ss64.com/bash/syntax-prompt.html
;::howto::cat ~/formatted_html ;; only works in Lynxspace (rwxdocker)

::lynxdump::lynx -dump "https://ss64.com/bash/syntax-prompt.html"  > ~/formatted_html


::normal red::PS1="export PS1='\[\e[31m\]\u@\h:\w\[\e[0m\] ' "

::cstyle::PS1="C:\> "

::xwolf::Exit[]

::wolf::wolframscript
::wo::

::startgui::explorer.exe "c:\users\Mechachleopteryx\.ubuntu"
::startgraphical::powershell.exe -command "invoke-item c:\users\Mechachleopteryx\.ubuntu\ubuntu.lnk"



;; spelling mistake ;;

::cd /user/bin::cd /usr/bin


::hashbang::!#/usr/bin/bash
::hb::!#/usr/bin/bash
::binbash::!#/bin/bash
::bb::!#/bin/bash

::forloop::
Send for i in 1 2 3 4 5;
Send do
Send, {Space}
Send        say "Hello World $i";
Send done
Send, {Enter}
Return


::hellocount::while true; do for i in 1 2 3 4 5; say "Hello $i"; sleep 3; done

::goodbuy::Say "I can see you're having trouble. Good-bye"

::tell me a story::Say "A sower went out to sow some seed: and as he sowed, some fell by the wayside; and it was trodden down, and the fowls of the air devoured it.

 And some fell upon a rock; and as soon as it was sprung up, it withered away, because it lacked moisture.

 And some fell among thorns; and the thorns sprang up with it, and choked it.

 And other fell on good ground, and sprang up, and bare fruit an hundredfold. And when he had said these things, he cried, He that hath ears to hear, let him hear.

 And his disciples asked him, saying, What might this parable be?

  And he said, Unto you it is given to know the mysteries of the kingdom of God: but to others in parables; that seeing they might not see, and hearing they might not understand. Now the parable is this... The seed is the word of God... Those by the wayside are they that hear; then cometh the devil, and taketh away the word out of their hearts, lest they should believe and be saved... They on the rock are they, which, when they hear, receive the word with joy; and these have no root, which for a while believe, and in time of temptation fall away... And that which fell among thorns are they, which, when they have heard, go forth, and are choked with cares and riches and pleasures of this life, and bring no fruit to perfection... But that on the good ground are they, which in an honest and good heart, having heard the word, keep it, and bring forth fruit with patience."

:*:normap::normal promp

;;  Programming Shortcuts
::Haplo::Haplopraxis
::clonemy::git clone https://github.com/standardgalactic/Haplopraxis
::ratelimit::curl -I https://api.github.com/users/standardgalactic

;;  Desktops
::phonehome::sftp bonobo@192`.168`.2`.40:projects
::phonemy::ssh bonobo@192.168.2.40 ;WSL
::archeo::ssh archeo@192.168.2.126 
::mixo::ssh mixo@192.168.2.81
::kodak::ssh kodak@192.168.2.142

::phewf::ssh phewf@192.168.2.128

;; chess monkey
::ches::ssh good@192.168.2.123
::monke::ssh monkey@192.168.2.124


;; start openssh server
::startssh::sudo systemctl start ssh

;;  Laptops

=======
::mymac::ssh mecha@192.168.2.233 ;os/10 shell zsh, brew


::flyx::ssh flyxion@172.27.178.246
::astro::ssh aardvark@192.168.2.73
::moontop::ssh moontop@192.168.2.113 ; ubuntu
::myoldlaptop::ssh eccehomo@192.168.2.30 ;;; now ubuntu 
::eccehomo::ssh eccehomo@192.168.2.30 ;;; now ubuntu 
::eh::ssh eccehomo@192.168.2.240

::shorthand::ssh shorthand@192.168.2.125  ;; shorthand@Optiplex
::multitech::ssh mixo@192.168.2.93 ;; mixo@lydian

;; Smartphones
::myphone::ssh u0_a330@192.168.2.72 -p 8022 ;linux ubuntu
::myoldphone::ssh u0_a502@192.168.2.10 -p 8022 ;linux ubuntu

::ssh9::ssh admin@192.168.2.108 -p 2222
::sshs::ssh admin@192.168.2.72 -p 2222

;; Tablet(s)

::mytab::ssh u0_a368@192.168.2.82 -p 8022


;;#o:: ; Win+P hotkey (changed it to o (oh) because win+p handles the projector)
;;
;;FileSelectFile, FilePath, S, %A_Desktop%, Save Screenshot, PNG (*.png)
;;if (ErrorLevel)    ; The user pressed Cancel
return

;;SplitPath, FilePath, FileName,, FileExt, FileNameNoExt
;;if (FileExt != "png")   ; Appends the .png file extension if it is not already present
;;  FilePath .= ".png", FileName .= ".png"
;;
;;WinWaitClose, Save Screenshot
;;Sleep, 200
;;
;;pToken := Gdip_Startup()
;;pBitmap := Gdip_BitmapFromScreen("0|0|" A_ScreenWidth "|" A_ScreenHeight)
;pBitmap := Gdip_BitmapFromHWND(WinActive("A"))
;;Gdip_SaveBitmapToFile(pBitmap, FilePath)
;;Gdip_DisposeImage(pBitmap)
;;Gdip_Shutdown(pToken)

;;Clipboard := "example.com/$" FileName

;;return


;;^/:: ;ctrl forward slash
;;run Explorer "C:\Users\tom\Desktop\Screenshots"
;;Return

;; '   ;;
;;!z:: ;alt z 
;;send {PrintScreen}
;;sleep, 2000
;;send ^d
;;Return

;; interferes with Biomenace in windows 3.1 ;;




/*
;;volume control;;;
^Up:: ;ctrl plus up arrow
sleep, 200
Send {Volume_Up}
Return

^Down:: ;ctrl plus down arrow
sleep, 200
Send {Volume_Down}
Return
*/

::linugist::linguist

::kindastrange::dͭoͪnͥˢ'tͥˢ ᵏyͥᶰoͩu ͦᶠtˢhͭiͬnͣᶰkᵍ
::strat::start
::amonsgt::amongst
::resumee::résumé
::resumees::résumés
::fcuk::fuck

;; ahkward soundboard ;;
::truef::Say "The words true and false are built-in constants containing 1 and 0. "
::kalibrate::Say "Testing 1, 2, 3, 4 ...  assay      ... calibrate      ... calibration       ... check something out       ... check up on somebody       ... crucible       ... experimental       ... experimentally       ... experimentation       ... experimenter       ... factorial       ... put out feelers       ... put somebody or something through their paces       ... put something to the test       ... road test       ... screening       ... spot check       ... spy out the land       ... try something out "

;; Symbols ;;

;------------------------------------------------------------------------------
; Science/engineering
;------------------------------------------------------------------------------
; Resistances using Greek uppercase omega character, not 
; Unicode ohm sign (which only exists for backwards compatibility)
;:c1*:ohm::Ω ; 
;;::ohm::Ω ; not useful ;; just use "omega"

::ooo::°
:*?:degC::°C ; degrees Celsius
:*?:degF::°F ; degrees Fahrenheit

:?*:+-::±   ; plus-or-minus sign
:?:|-::−    ; true minus sign
:?:|minus::−  ; true minus sign
:?:|x::×    ; true times sign
:?:|times::×
::divby::÷  ; division sign or obelus
;; ::./.::÷    ; any conflicts? -- yes. can't do cd ../.. it does cd .÷.

:?:|*::⋅    ; "dot operator" (&sdot;), for multiplication, dot product

; sdot   ⋅ U+22C5 HTML symbol dot operator ('dot operator' is NOT the same character as U+00B7 'middle dot'.)

/*
; Experimental: Multiply by
:?:1x::1×
:?:2x::2×
:?:3x::3×
:?:4x::4×
:?:5x::5×
:?:6x::6×
:?:7x::7×
:?:8x::8×
:?:9x::9×
*/

; "Unicode also includes a handful of vulgar fractions as compatibility characters, but discourages their use."
::|1/2::½
::|1/4::¼
::|3/4::¾


::|>=::≥   ; '>=' conflicts with usage in programming.  Alternatively, it could specify different rules for code windows.
::|<=::≤
::|!=::≠ ; not equal to
::|>>::≫ ; much greater than
::|<<::≪ ; much less than
::|!=::≠
::notequal::≠
::approx::≈ ; approximately equal to
::asymp::≈
::|~::≈
::|propto::∝ ; proportional to
::|=-::≡     ; mathematical identity
::|===::≡
::|propersubset::⊂    ; SUBSET OF
::|propersuperset::⊃  ; SUPERSET OF
::|notsubset::⊄ ; NOT A SUBSET OF
::|subset::⊆  ; SUBSET OF OR EQUAL TO
::|superset::⊇  ; SUPERSET OF OR EQUAL TO 

; superscripts and subscripts from HTML entity names sup2 and sup3
; Examples: km² V₊ V₋ CuSO₄·5H₂O or ²³⁸U (hard to type, ugly, but actually used, according to Google)
; Alternate notation: x^2 → x², x_2 → x₂
; Of course, that would conflict with programming variable names like max_3
; There's also ⁼⁽⁾₌₍₎ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻᴬᴮᴰᴱᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᴿᵀᵁⱽᵂₐₑₕᵢₖₗₘₙₒₚᵣₛₜᵤᵥₓᵅᵝᵞᵟᵋᶿᶥᶲᵠᵡᵦᵧᵨᵩᵪ

::special scripts::⁼⁽⁾₌₍₎ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻᴬᴮᴰᴱᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᴿᵀᵁⱽᵂₐₑₕᵢₖₗₘₙₒₚᵣₛₜᵤᵥₓᵅᵝᵞᵟᵋᶿᶥᶲᵠᵡᵦᵧᵨᵩᵪ

:?:sup0::⁰
:?:sup1::¹
:?:sup2::² ; common
:?:sup3::³ ; common
:?:sup4::⁴
:?:sup5::⁵
:?:sup6::⁶
:?:sup7::⁷
:?:sup8::⁸
:?:sup9::⁹
:?:sup+::⁺
:?:sup-::⁻
:?:supn::ⁿ
:?:supi::ⁱ

:?:sub0::₀
:?:sub1::₁
:?:sub2::₂
:?:sub3::₃
:?:sub4::₄
:?:sub5::₅
:?:sub6::₆
:?:sub7::₇
:?:sub8::₈
:?:sub9::₉
:?:sub+::₊
:?:sub-::₋

::square!::√ ; square root
::infinity!::∞

;------------------------------------------------------------------------------
; Typography / symbols
;------------------------------------------------------------------------------
::|c::©   ; copyright symbol
::(c)::©
::|r::®   ; registered symbol
::(r)::®
::|s::§   ; section symbol
::(tm)::™ ; trademark symbol

;; ○ ● ● ○ ○ ● ● ○ circles
::a little black dot::• ; a bullet
::fcirc::● ; filled circle
::hcirc::○ ; hollow circle


; Arrows
:?*:--->::→
:?*:==>::⇒
:?*:<---::←
:?*:<==::⇐
:?*:<->::↔
:?*:<=>::⇔
::|^::↑
::|v::↓

;------------------------------------------------------------------------------
; HTML shortcuts
;------------------------------------------------------------------------------

;; htmlsh ;;

/*
;;
:*:sw::<a href="
:*:ws::
Send, "> </a>
Send, {Esc}
Send, 4h
Return
;;
*/

::htm plate::
(
<html>
    <head>
        <title>Go, Forth, and Multiply</title>
    </head>
    <body>
        <ul>
            <li>
                <a href="#">http://wiki.laptop.org/go/Forth_Lessons</a>
            </li>
        </ul>
    </body>
</html>
)

::exsample::
(
<html>
    <head>
        <title>Site Map</title>
    </head>
    <body>
        <ul>
            <li>
                <a href="index.html">Home</a>
            </li>
<li>
                <a href="products/index.html">Products</a>
            </li>
<li>
                <a href="about.html">About</a>
            </li>
        </ul>
    </body>
</html>
)


:*b0:|bq::{bs 3}<blockquote></blockquote>{left 13}
; :*:|bq::<blockquote>
:*:|/bq::</blockquote>
:*:|\bq::</blockquote>

:*b0:|qu::{bs 3}[QUOTE][/QUOTE]{left 8}
:*:|/qu::[/QUOTE]
:*:|\qu::[/QUOTE]

:*b0:<em>::</em>{left 5}

;; test this someday ;;

;t_str = 
;(
;a test
;another 
;test
;)
;msgbox % t_str
;------------------------------------------------------------------------------
; Insert timestamp 2021-12-30 07:44:19 PM - works
;------------------------------------------------------------------------------
; Should be a keyboard shortcut or a phrase?
; Needs to be compatible with spreadsheet formats

;; 2022-02-18 09:30:26 AM still works
+!t:: ;Shift-Alt-D: Insert current date and time stamp
FormatTime, T, %A_Now%, yyyy-MM-dd hh:mm:ss tt ; 2012-01-24 10:54:31 PM - works in LibreOffice, Google Spreadsheet, Excel
SendInput %T%
return

::thedate:: ;Insert current date
FormatTime, T, %A_Now%, yyyy-MM-dd ; 2011-07-25
SendInput %T%
return

::thetime:: ;Insert current time
FormatTime, T, %A_Now%, hh:mm:sstt ; 09:24:20AM
SendInput %T%
return

;------------------------------------------------------------------------------
; Make windows transparent
;------------------------------------------------------------------------------
#T::
DetectHiddenWindows, on
WinGet, curtrans, Transparent, A
if !curtrans
	curtrans := 255
newtrans := curtrans - 64
if (newtrans > 0) {
	WinSet, Transparent, %newtrans%, A
} else {
	WinSet, Transparent, 255, A
	WinSet, Transparent, OFF, A
}
return

;------------------------------------------------------------------------------
; Darken window
;------------------------------------------------------------------------------
#W::
DetectHiddenWindows, on
WinSet, TransColor, Black 128, A
return

;------------------------------------------------------------------------------
; Reset transparency
;------------------------------------------------------------------------------
#O::
WinSet, Transparent, 255, A
WinSet, Transparent, OFF, A
return



;; useful but I can't seem to make it go away afterward ;;

;#g::  ; Press Win+G to show the current settings of the window under the mouse.
;MouseGetPos,,, MouseWin
;WinGet, Transparent, Transparent, ahk_id %MouseWin%
;WinGet, TransColor, TransColor, ahk_id %MouseWin%
;ToolTip Translucency:`t%Transparent%`nTransColor:`t%TransColor%
;WinGet, ActiveControlList, ControlList, A
; Loop, Parse, ActiveControlList, `n
;{
;    MsgBox, 4,, Control #%A_Index% is "%A_LoopField%". Continue?
;    IfMsgBox, No
;        break
;}
;return

#MaxThreadsPerHotkey 2 ; Allows the hotkey to be interruptible.

#g::  ; Press Win+G to show the current settings of the window under the mouse.
If (ToolTipActive = 1)  ; If a tooltip is currently showing...
{
    SetTimer, RemoveToolTip, Off  ; Stop the timer.
    ToolTipActive := 0  ; Reset the state.
    ToolTip  ; Remove the tooltip.
    return
}
MouseGetPos,,, MouseWin
WinGet, Transparent, Transparent, ahk_id %MouseWin%
WinGet, TransColor, TransColor, ahk_id %MouseWin%
WinGet, ProcessName, ProcessName, ahk_id %MouseWin%
WinGet, ProcessName, ProcessName, ahk_id %MouseWin%
WinGet, ControlList, ControlListHwnd, ahk_id %MouseWin%

ToolTip Translucency:`t%Transparent%`nTransColor:`t%TransColor% `nProcessName:`t%ProcessName%`nControlList:`t%ControlList%

ToolTipActive := 1  ; Signal that a tooltip is currently showing.
SetTimer, RemoveToolTip, -2500  ; Set a one-shot timer to remove the tooltip after 2.5 seconds.
return

RemoveToolTip:
ToolTip  ; Remove the tooltip.
ToolTipActive := 0  ; Reset the state.
return



;; notes on hotstring helper ;; hostringsh

::winh::Hotstring Helper

;; ahk parameters ;;

::ahkpar::
(
NumParams = %0%
Param1 = %1%
Param2 = %2%
Param3 = %3%
MsgBox NumParams = %0%
MsgBox Param1 = %1%
MsgBox Param2 = %2%
MsgBox Param3 = %3%
)

::newscript::
(
#NoTrayIcon              ;if you don't want a tray icon for this AutoHotkey program.
#NoEnv                   ;Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force    ;Skips the dialog box and replaces the old instance automatically
;;SendMode Input           ;I discovered this causes MouseMove to jump as if Speed was 0. (was Recommended for new scripts due to its superior speed and reliability.)
SetKeyDelay, 90          ;Any number you want (milliseconds)
CoordMode,Mouse,Screen   ;Initial state is Relative
CoordMode,Pixel,Screen   ;Initial state is Relative. Frustration awaits if you set Mouse to Screen and then use GetPixelColor because you forgot this line. There are separate ones for: Mouse, Pixel, ToolTip, Menu, Caret
MouseGetPos, xpos, ypos  ;Save initial position of mouse
WinGet, SavedWinId, ID, A     ;Save our current active window

;Set Up a Log File:
SetWorkingDir, %A_ScriptDir%  ;Set default directory to where this script file is located. (Note %% because it's expecting an unquoted string)
LogFile := "MyLog.txt"
FileAppend,    ``n, %LogFile%  ;     ````. (Note %% because it's expecting an unquoted string)
)


#Persistent
#SingleInstance Force
SetTitleMatchMode, 2

F12:: ; Press F12 to trigger the script
    Sleep, 200
    SendInput, ^a ; Send Ctrl+A
    Sleep, 100
    SendInput, [  ; Enter tmux select mode
    Sleep, 300
    SendInput, {Up} ; Move to the last line (adjust if needed)
    Sleep, 200
    SendInput, {Space} ; Start selection
    Sleep, 100
    SendInput, {0} ; Move to beginning to select the full command
    Sleep, 200
    SendInput, {Enter} ; Copy selection
    Sleep, 100
    SendInput, ^a ; Send Ctrl+A
    Sleep, 100
    SendInput, ]  ; Exit select mode (optional)
    Sleep, 100
    SendInput, {Enter} ; Execute copied command
return



;; Printscreen to random name ;;

/*
PrintScreen::
    Send, #{Vk2CSc137}
    Sleep, 100
    Run, mspaint
    WinWait, Untitled - Paint
    WinActivate
    Sleep, 500
    Send, ^v
    Send, ^q
    Sleep, 500
    Send, ^s
    Sleep, 1000
    Send, ^v
    Sleep, 500
    Send, {Enter}
    WinClose
    return
*/

;; Source for easy peasy
; added this from the command line, source -- internet -- A few functions comes out of the box to help us with Lists:head returns the first element and last the last one (be careful, it is not tail, tail will give you the whole list minus the first element). Then length  returns the number of elements in the list. Easy peasy.

;; enyay spanish ;;
:o:n~::ñ

::Anything below h::Anything below this point was added to the script by the user via the Win+H hotkey.
::catually::actually
::antything::anything
::aynthing::anything
::concat::concatenate
::ep::Easy peasy. 
::owrks::works
::exit90::exit()
::xx::exit()
::exiut::exit
::pygrame::pygame
::exitt::exit
::exti::exit
::godda::got to
::hotsh::Hotstring Helper`rAndreas Borutta suggested the following script, which might be useful if you are a heavy user of hotstrings. By pressing Win+H (or another hotkey of your choice), the currently selected text can be turned into a hotstring. For example, if you have "by the way" selected in a word processor, pressing Win+H will prompt you for its abbreviation (e.g. btw) and then add the new hotstring to the script. It will then reload the script to activate the hotstring.
::wroks::works
::specail::special
::claer::clear
