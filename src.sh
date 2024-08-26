#!/bin/bash
# site emoji => https://copychar.cc/symbols/ 

# Emoji
NAVIGATION_ARROW='➙'
CHECKBOX_TRUE="☒"
CHECKBOX_FALSE="☐"

# Font style
font_red_S='\e[1;31m'; font_red_E='\e[0m';
font_purple_S='\e[1;35m' font_purple_E='\e[0m'
font_white_S='\e[38;2;255;255;255m'; font_white_E='\e[0m'

# Bash var
DAY=$(date +%d)
MONTH=$(date +%B)
DATE=$(date +%Y-%m-%d)

# Infra - Diretório de armazenamento
STORAGE_DIR_MY_LOG_2036=~/my-log-2036/$MONTH
# STORAGE_DIR_MY_LOG_2036_CONTENT="$HOME/my-log-2036/$MONTH"

function generate_navigation_layout {    
    local index=0
    local path=''
    local last_element=$(($# - 1))

    for name in "$@"; do
        if (( index > 0 )); then
            path+=" $NAVIGATION_ARROW "
        fi 

        if (( index == last_element )); then
            path+="${font_purple_S}$name${font_purple_E}"
            break
        fi
            
        path+="$name"
        ((index++))
    done

    printf "> $path\n\n"
}

function main {
    clear;
    generate_navigation_layout "home"
    printf "#WELCOME BACK $NAME \n"
    menu "list all my files" "See tasks for the day" "log out or Ctrl + c"

    while true; do
        read -p "type: " selected_task

        case $selected_task in
            1) menu_user_files; exit ;;
            2) see_tasks_for_the_day; exit ;;
            3) stop_script ;;
            *) printf "\e[1;31mInvalid input: $selected_task. Try again!\n\e[0m\n" ;;
        esac
    done
}

function see_tasks_for_the_day {
    check_if_the_day_file_was_created
    clear; 
    generate_navigation_layout "home" "see-tasks-of-the-day"
    check_if_the_file_created_is_empty
    get_data_from_file_and_create_array_of_tasks "day-$DAY"
    menu "back" "add new" "adit file" "mark as done"
    
    while true; do
        read -p "type: " answer
    
        case $answer in 
            1) main ;;
            2) add_new_task_to_be_done_today ;;
            3) edit_todays_file ;;
            4) mark_task_as_complete ;;
            *) printf "\e[1;31mInvalid input: $answer. Try again!\n\e[0m\n" ;;
        esac
    done 
}

function mark_task_as_complete {
    mapfile -t array_task_list < "$STORAGE_DIR_MY_LOG_2036/day-$DAY"

    while true; do
        read -p "Which task have you finished [c]? " answer

        # check if the answer is 'c' 
        [ "$answer" = "c" ] && see_tasks_for_the_day && continue

        # check if the answer is a number 
        if [[ ! "$answer" =~ ^[0-9]+$ ]]; then
            echo -e "${font_red_S}Invalid input. Please enter 'c' or a valid number.${font_red_E}"
            continue
        fi

        # Check if the number is within the valid range of the array
        if [ "$answer" -gt "${#array_task_list[@]}" ] || [ "$answer" -lt 0 ]; then
            echo -e "${font_red_S}Invalid input. Please enter a number within the valid range${font_red_E}"
            continue
        fi

        # Processa a tarefa selecionada
        task_changed=$(echo "${array_task_list[$answer]}" | sed 's/[☐☒] //g')
        current_status="${array_task_list[$answer]}"
        new_status="$CHECKBOX_TRUE $task_changed"

        # Verifica o estado atual e inverte o status
        if [ "$current_status" = "$CHECKBOX_TRUE $task_changed" ]; then
            new_status="$CHECKBOX_FALSE $task_changed"
        fi

        # Atualiza o array e o arquivo com o novo status
        array_task_list[$answer]=$new_status
        printf "%s\n" "${array_task_list[@]}" > "$STORAGE_DIR_MY_LOG_2036/day-$DAY"

        # Exibe as tarefas atualizadas
        see_tasks_for_the_day
    done
}

function get_data_from_file_and_create_array_of_tasks  {
    mapfile -t array_task_list < "$STORAGE_DIR_MY_LOG_2036/$1"

    index=0
    for task_name in "${array_task_list[@]}"; do
        echo "$index. $task_name"
        ((index++))
    done
}

function check_if_the_day_file_was_created {
    if [ ! -f "$STORAGE_DIR_MY_LOG_2036/day-$DAY" ]; then
        while true; do
            read -p "you havent created the file for today! do you want to (y/n)? " answer

            case $answer in 
                y | yes | YES)
                    touch "$STORAGE_DIR_MY_LOG_2036/day-$DAY"
                    clear; 
                    see_tasks_for_the_day; 
                    return 0;;
                n | no | NO)
                    clear; 
                    echo "If you change your mind came back here later!"
                    return 1;;
                *)
                    printf "invalid answer: $answer!  try again!\n" ;;
            esac 
        done
    fi
}

function check_if_the_file_created_is_empty {
    if [ ! -s "$STORAGE_DIR_MY_LOG_2036/day-$DAY" ]; then
        echo -e "\e[1;38;5;208mYou haven't added any task yet!\e[0m"

        while true; do
            menu "back" "add new task"
            read -p "type: " answer;

            case $answer in 
                1) clear; main;;
                2) add_new_task_to_be_done_today;;
                *) printf "\e[1;31mInvalid input: $answer. Try again!\n\e[0m\n" ;;
            esac 
        done
    fi
}

function add_new_task_to_be_done_today {
    clear; 
    generate_navigation_layout "home" "see-tasks-of-the-day" "add-new-task"
    printf "task_name [c]: "; read task_name

    [ "$task_name" = 'c' ] && see_tasks_for_the_day;
    
    echo "$CHECKBOX_FALSE $task_name" >> "$STORAGE_DIR_MY_LOG_2036/day-$DAY"
    see_tasks_for_the_day
}

function menu_user_files {
    clear; 
    generate_navigation_layout "home" "all-files"
    ls "$STORAGE_DIR_MY_LOG_2036"
 
    while true; do
        menu "back" "view file" "edit file" "log out"
        printf "type🎹: "; read answer;

        case $answer in
            1) clear; main; exit;;
            2) view_file; exit;; 
            3) edit_file; exit;;
            4) stop_script; exit;;
            *) printf "\e[1;31mInvalid input: $selected_task. Try again!\n\e[0m\n";;
        esac 
    done
}

function view_file {
    while true; do
        read -p "> which file do you wanna open [c]? " file_name_will_be_opened

        [ "$file_name_will_be_opened" = c ] && menu_user_files

        if [ -f "$STORAGE_DIR_MY_LOG_2036/$file_name_will_be_opened" ]; then
            clear
            generate_navigation_layout "home" "all-my-files" "viewing-file-$file_name_will_be_opened"
            get_data_from_file_and_create_array_of_tasks "$file_name_will_be_opened"

            while true; do
                menu "back" "log out"
                printf "type🎹: "; read answer;

                case $answer in
                    1) menu_user_files;;
                    2) stop_script;;
                    *) printf "\e[1;31mInvalid input: $answer. Try again!\n\e[0m\n" ;;
                esac
            done
        fi

        printf "\e[1;31mInvalid input: $answer. Try again!\n\e[0m\n"
    done
}

function edit_file {
    while true; do
        printf "> which file do you wanna edit [c]? "; read file_name
        menu

        if [ -f "$STORAGE_DIR_MY_LOG_2036/$file_name" ]; then
            vim "$STORAGE_DIR_MY_LOG_2036/$file_name";
            menu_user_files
        fi

        [ "$file_name" = 'c' ] && menu_user_files;
        printf "\e[1;31mInvalid input: $file_name. Try again!\n\e[0m\n"
    done
}

function edit_todays_file {
    vim "$STORAGE_DIR_MY_LOG_2036/day-$DAY"; printf "\n"
    see_tasks_for_the_day
}

function menu {
    index=1
    last_index=$#

    for option_name in "$@"; do
        ((index == 1)) && printf "\n";
        printf "$index) $option_name\n"
        ((index == last_index)) && printf "\n"
        ((index++))
    done
}

function stop_script {
    echo "log out"; exit
}

function create_dir_to_save_task {
    if [ ! -d "$HOME/my-log-2036" ] && [ ! -d "$STORAGE_DIR_MY_LOG_2036" ]; then
        mkdir "$HOME/my-log-2036"
        mkdir "$STORAGE_DIR_MY_LOG_2036"
        echo "Diretório criado: $TARGET_DIR"
        return 1
    fi
}

create_dir_to_save_task
main