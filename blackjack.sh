#!/usr/bin/bash

# The '-d' option may be used to specify the delay between messages:
  #   ./bashjack.sh -d '0.2'
getopts "d:" message_delay

message_delay=${OPTARG:-"1"}

# declaring the 3 basic arrays i.e. for player, dealer and deck
declare -a deck player_hand dealer_hand

# function for creating a new deck of cards and respective suites
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
# Outputting names of all possible card combinations
    for suite in ${suites[@]}; do
        for card in ${cards[@]}; do
            echo "$suite|$card"
        done
    done
}
# Function to check and output the suite of card
function card_suite
{
    echo "$1" | cut --delimiter="|" --fields="1,1"
}
# Function to check and output the name of card
function card_name
{
    echo "$1" | cut --delimiter="|" --fields="2,2"
}
# Function to check and output the suite of card
function card_value
{
    echo "$1" | cut --delimiter="|" --fields="3,3"
}

# Function to check Whether the card is an ACE or not and return a True or False Value
function card_is_ace
{
    [[ "$(card_name $1)" == "Ace" ]]
}

# Function to check Whether the card is an Face or not and return a True or False Value
function card_is_face
{
    pattern='^(Jack|Queen|King)$'
    [[ "$(card_name $1)" =~ $pattern ]]
}

# Function to output the full name of the card (drawn or displayed)
function card_full_name
{
    echo "$(card_name $1) of $(card_suite $1)"
}

# Function to yield and display the abbreviation of the card
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

# Function to calculate the value of cards in hand of the player
function hand_value
{
    sorted_hand=($(echo "$@" | tr ' ' "\n" | sort --field-separator='|' --key='3,3n'))

    declare -i value=0
# using for loop to calculate total value of all the cards in Player's/dealers's hand
    for card in ${sorted_hand[@]}; do
        card_value=$(card_value $card)
        value=$((value + card_value))
    done
# Checking and computing the value of the card if its an ace and adding to total
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

# Function to calculate and output the abbreviation of all the cards in player's hand
function hand_abbreviation
{
    echo -n "( "
    for card in $@; do
        echo -n "$(card_abbreviation $card) "
    done
    echo ")"
}

# Function to check that is the player BUSTED or not i.e. is value > 21 or not
function hand_is_bust
{
    [[ $(hand_value $@) -gt 21 ]]
}

# Checking that is the player's cards inhand value equal to 21 or not
# Checking that is it a BlackJack or not
function hand_is_blackjack
{
    [[ $# -eq 2 && $(hand_value $@) -eq 21 ]]
}

# Function to cause a delay in output to smoothen the game
function echo_with_delay
{
    echo -e $@
    sleep $message_delay
}

# Function to automatically draw the first/top card from deck as being the dealer and displaying the card drawn
function hit_dealer
{
    card=${deck[0]}
    deck=(${deck[@]:1})
    dealer_hand+=($card)

    echo_with_delay "\nDealer draws $(card_full_name $card)"
}

# Function to draw the first/top card from deck as being the Player and displaying the card drawn
function hit_player
{
    card=${deck[0]}
    deck=(${deck[@]:1})
    player_hand+=($card)

    echo_with_delay "\nPlayer draws $(card_full_name $card)"
}

# Function to handle the Player's Turn
function player_turn
{
    input=""
# A repeat-until loop used to continuously input a 'h' or 's' value for playing the game until the player wins or loses or decides to stay
    until [[ $input == "s" ]]; do
        echo_with_delay "\nPlayer hand: $(hand_value ${player_hand[@]}) $(hand_abbreviation ${player_hand[@]})\n\n(h)it or (s)tay?"
# Taking the input
        read -s -n 1 input
        input=${input,,}
# Checking the input and calling the respective function
        if [[ $input == "h" ]]; then
            hit_player
# Yielding a 1 value if its a bust
            if hand_is_bust ${player_hand[@]}; then
                return 1;
            fi
        fi
    done

    echo_with_delay "\nPlayer stays."

    return 0;
}

# Function to handle the Dealer's Turn
function dealer_turn
{
#  Outputting the cards that dealer has in hand and their values and abbreviations
    echo_with_delay "\nDealer reveals $(card_full_name ${dealer_hand[1]})."

    dealer_hand_value=$(hand_value ${dealer_hand[@]})

    echo_with_delay "\nDealer hand: $dealer_hand_value $(hand_abbreviation ${dealer_hand[@]})."

#     again displaying the values of cards that player has in his hand

    player_hand_value=$(hand_value ${player_hand[@]})

# Using a repeat-until loop to continue process until dealers cards value exceeds 17or is greater than value of player's cards
    until [[ $dealer_hand_value -ge 17 || $dealer_hand_value -gt $player_hand_value ]]; do
        hit_dealer
# Checking the value of cards in dealers hands and outputting them with abbreviations
        dealer_hand_value=$(hand_value ${dealer_hand[@]})

        echo_with_delay "\nDealer hand: $dealer_hand_value $(hand_abbreviation ${dealer_hand[@]})."
    done
# Checking that the dealers is BUSTED or not and quit game if its busted or else continue
    if hand_is_bust ${dealer_hand[@]}; then
        return 1;
    fi

    echo_with_delay "\nDealer stays."

    return 0
}

# Function to start and handle a new game
function new_game
{
#   Creating a new deck of cards and shuffling them
    deck=($(new_deck | shuf))
# Assigning random cards to dealer and player respectively
    player_hand=(${deck[@]:0:2})
    dealer_hand=(${deck[@]:2:2})

    deck=(${deck[@]:4})
# Displaying details of the card that the player draws
    echo_with_delay "\nPlayer draws $(card_full_name ${player_hand[0]}) and $(card_full_name ${player_hand[1]})."

# Checking that is anyone of player or ealer become a blackJack or not
# and then displaying the cards dealer has
    if hand_is_blackjack ${player_hand[@]}; then
        if hand_is_blackjack ${dealer_hand[@]}; then
            echo_with_delay "\nDealer has $(card_full_name ${dealer_hand[0]}) and $(card_full_name ${dealer_hand[1]})."
# if both are black jack, then its a draw
            echo_with_delay "\nBoth players have blackjack. Game is a draw."
        else
#          otherwise displaying a BlackJack text to symbolize that Player has won
            echo_with_delay "\nBlackjack!"
        fi

        return
#        If player is not a black jack, we check the dealers cards exclusively
    elif hand_is_blackjack ${dealer_hand[@]}; then
        echo_with_delay "\nDealer has $(card_full_name ${dealer_hand[0]}) and $(card_full_name ${dealer_hand[1]})."
# displaying a statement of "Dealer wins" if he has a black-jJack
        echo_with_delay "\nDealer has blackjack. Dealer wins."
        return
    fi
# Otherwise,  we display the cards dealer has in hand
    echo_with_delay "\nDealer shows $(card_full_name ${dealer_hand[0]})."

# Check that players cards value exceeds 21 or not.
    if ! player_turn; then
#       if cards value exceeds 21 then BUSTED is displayed and game over
        echo_with_delay "\nPlayer bust."
        return
    fi
# Check that Dealers cards value exceeds 21 or not.
    if ! dealer_turn; then
#        if cards value exceeds 21 then BUSTED is displayed and game over
        echo_with_delay "\nDealer bust."
        return
    fi
# If no one is busted, then we recalculate the values of cards both the playes have in hand respectively
    player_hand_value=$(hand_value ${player_hand[@]})
    dealer_hand_value=$(hand_value ${dealer_hand[@]})
# Displaying the value of cards both players have in hand
    echo_with_delay "\nPlayer has $player_hand_value. Dealer has $dealer_hand_value."

# Checking and comparing the values of cards both player and dealer have in hand and then outputting the text if one wins or if its a draw
    if [[ $player_hand_value -gt $dealer_hand_value ]]; then
        echo_with_delay "\nPlayer wins."
    elif [[ $player_hand_value -lt $dealer_hand_value ]]; then
        echo_with_delay "\nDealer wins."
    else
        echo_with_delay "\nGame is a draw."
    fi
}

# Function to handle the Main Menu that gives the option to play or quit
function menu_loop
{
    input=""
# repeating until the value is q that translates to quitting the game. A repeat-until loop is used
    until [[ $input == "q" ]]; do
        echo_with_delay "\n(p)lay or (q)uit?"
        read -s -n 1 input
        input=${input,,}
# if the input is 'p' then we sr=tart a new game
        if [[ $input == "p" ]]; then
            new_game
        fi
    done

    return 0
}
# call the main loop function to run the entire program
menu_loop

exit 0