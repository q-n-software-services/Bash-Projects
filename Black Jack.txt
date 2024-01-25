#!/usr/bin/bash
#
# Simple Blackjack game written in Bash. To play, give this file
# execute permissions and run it:
#   chmod u+x bashjack.sh
#   ./bashjack.sh
#
# Alternatively you can run Bash with this file as an argument:
#   bash bashjack.sh
#
# Input keys are indicated by single characters surrounded by
# brackets. For example, '(h)it' can be read as 'Press h to hit.'
#
# The '-d' option may be used to specify the delay between messages:
#   ./bashjack.sh -d '0.2'
#
# This value is passed as an argument to the `sleep` command, and 
# defaults to '1'.
#
# Written by Seb Jones (https://sebj.co.uk)

getopts "d:" message_delay

message_delay=${OPTARG:-"1"}

declare -a deck player_hand dealer_hand

function new_deck
{
    cards=(
        "Two|2"
        "Three|3"
        "Four|4"
        "Five|5"
        "Six|6"
        "Seven|7"
        "Eight|8"
        "Nine|9"
        "Ten|10"
        "Jack|10"
        "Queen|10"
        "King|10"
        "Ace|1"
    )

    suites=(
        "Diamonds"
        "Hearts"
        "Clubs"
        "Spades"
    )

    for suite in ${suites[@]}; do
        for card in ${cards[@]}; do
            echo "$suite|$card"
        done
    done
}

function card_suite
{
    echo "$1" | cut --delimiter="|" --fields="1,1"
}

function card_name
{
    echo "$1" | cut --delimiter="|" --fields="2,2"
}

function card_value
{
    echo "$1" | cut --delimiter="|" --fields="3,3"
}

function card_is_ace
{
    [[ "$(card_name $1)" == "Ace" ]]
}

function card_is_face
{
    pattern='^(Jack|Queen|King)$'
    [[ "$(card_name $1)" =~ $pattern ]]
}

function card_full_name
{
    echo "$(card_name $1) of $(card_suite $1)"
}

function card_abbreviation
{
    if (card_is_face $1 || card_is_ace $1); then
        name=$(card_name $1)
        name=${name:0:1}
    else
        name="$(card_value $1)"
    fi

    suite=$(card_suite $1)

    echo "$name-${suite:0:1}"
}

function hand_value
{
    sorted_hand=($(echo "$@" | tr ' ' "\n" | sort --field-separator='|' --key='3,3n'))

    declare -i value=0

    for card in ${sorted_hand[@]}; do
        card_value=$(card_value $card)
        value=$((value + card_value))
    done

    if [[ $value -lt 12 ]]; then
        for card in ${sorted_hand[@]}; do
            if card_is_ace $card; then
                value+=10
            fi

            if [[ $value -gt 12 ]]; then
                break
            fi
        done
    fi

    echo $value
}

function hand_abbreviation
{
    echo -n "( "
    for card in $@; do
        echo -n "$(card_abbreviation $card) "
    done
    echo ")"
}

function hand_is_bust
{
    [[ $(hand_value $@) -gt 21 ]]
}

function hand_is_blackjack
{
    [[ $# -eq 2 && $(hand_value $@) -eq 21 ]] 
}

function echo_with_delay 
{
    echo -e $@
    sleep $message_delay
}

function hit_dealer
{
    card=${deck[0]}
    deck=(${deck[@]:1})
    dealer_hand+=($card)

    echo_with_delay "\nDealer draws $(card_full_name $card)"
}

function hit_player
{
    card=${deck[0]}
    deck=(${deck[@]:1})
    player_hand+=($card)

    echo_with_delay "\nPlayer draws $(card_full_name $card)"
}

function player_turn
{
    input=""

    until [[ $input == "s" ]]; do
        echo_with_delay "\nPlayer hand: $(hand_value ${player_hand[@]}) $(hand_abbreviation ${player_hand[@]})\n\n(h)it or (s)tay?"

        read -s -n 1 input
        input=${input,,}

        if [[ $input == "h" ]]; then
            hit_player

            if hand_is_bust ${player_hand[@]}; then
                return 1;
            fi
        fi
    done

    echo_with_delay "\nPlayer stays."

    return 0;
}

function dealer_turn
{
    echo_with_delay "\nDealer reveals $(card_full_name ${dealer_hand[1]})."

    dealer_hand_value=$(hand_value ${dealer_hand[@]})

    echo_with_delay "\nDealer hand: $dealer_hand_value $(hand_abbreviation ${dealer_hand[@]})."

    player_hand_value=$(hand_value ${player_hand[@]})

    until [[ $dealer_hand_value -ge 17 || $dealer_hand_value -gt $player_hand_value ]]; do
        hit_dealer

        dealer_hand_value=$(hand_value ${dealer_hand[@]})

        echo_with_delay "\nDealer hand: $dealer_hand_value $(hand_abbreviation ${dealer_hand[@]})."
    done

    if hand_is_bust ${dealer_hand[@]}; then
        return 1;
    fi

    echo_with_delay "\nDealer stays."

    return 0
}

function new_game
{
    deck=($(new_deck | shuf))

    player_hand=(${deck[@]:0:2})
    dealer_hand=(${deck[@]:2:2})

    deck=(${deck[@]:4})

    echo_with_delay "\nPlayer draws $(card_full_name ${player_hand[0]}) and $(card_full_name ${player_hand[1]})."

    if hand_is_blackjack ${player_hand[@]}; then
        if hand_is_blackjack ${dealer_hand[@]}; then
            echo_with_delay "\nDealer has $(card_full_name ${dealer_hand[0]}) and $(card_full_name ${dealer_hand[1]})."

            echo_with_delay "\nBoth players have blackjack. Game is a draw."
        else
            echo_with_delay "\nBlackjack!"
        fi

        return
    elif hand_is_blackjack ${dealer_hand[@]}; then
        echo_with_delay "\nDealer has $(card_full_name ${dealer_hand[0]}) and $(card_full_name ${dealer_hand[1]})."

        echo_with_delay "\nDealer has blackjack. Dealer wins."
        return
    fi

    echo_with_delay "\nDealer shows $(card_full_name ${dealer_hand[0]})."

    if ! player_turn; then
        echo_with_delay "\nPlayer bust."
        return
    fi

    if ! dealer_turn; then
        echo_with_delay "\nDealer bust."
        return
    fi

    player_hand_value=$(hand_value ${player_hand[@]})
    dealer_hand_value=$(hand_value ${dealer_hand[@]})

    echo_with_delay "\nPlayer has $player_hand_value. Dealer has $dealer_hand_value."

    if [[ $player_hand_value -gt $dealer_hand_value ]]; then
        echo_with_delay "\nPlayer wins."
    elif [[ $player_hand_value -lt $dealer_hand_value ]]; then
        echo_with_delay "\nDealer wins."
    else
        echo_with_delay "\nGame is a draw."
    fi
}

function menu_loop
{
    input=""

    until [[ $input == "q" ]]; do
        echo_with_delay "\n(p)lay or (q)uit?" 
        read -s -n 1 input
        input=${input,,}

        if [[ $input == "p" ]]; then
            new_game
        fi
    done

    return 0
}

menu_loop

exit 0