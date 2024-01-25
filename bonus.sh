#!/usr/bin/bash
#
# Bonus and salary calculator written in Bash. To run, give this file
# execute permissions and run it:
#   chmod u+x bonus.sh
#   ./bonus.sh
#
# Alternatively you can run Bash with this file as an argument:
#   bash bonus.sh



getopts "d:" message_delay

message_delay=${OPTARG:-"1"}

# Declaring Variables with Average Cost of Respective cars/models
A_class_cost=31095
B_class_cost=33162
C_class_cost=42537
E_class_cost=54437
AMG_C65_cost=79660

# Declaring basic salary as pre-defined
basic_salary=2000
# Declaring arrays for manipulating and storing bulk data for employees
declare -a Names
declare -a netSalary
declare -a grossSalary

# Taking Input for the number of Sales-Persons Present
echo "Enter the Number of Salespersons"
read salespersons_count

# Validating the input value to be between 3 and 20 Inclusive
while [[ $salespersons_count -le $((2)) ||  $salespersons_count -gt $((20)) ]] ; do
   echo "Enter the Number of Salespersons between 3 and 20 inclusive"
    read salespersons_count
done


# Inputting file name for the data file that would be yielded
echo "Enter File Name"
read file
# Inputting file path for the data file that would be yielded
echo "Enter Path for file"
read path

# A for loop from 1 to 12 for Inputting the data for 12 months for all the Sales Persons present
for i in {1..12}
do
    echo $i
# Inputting the name of month for which data is to be entered
echo "Enter Name of the month"
  read month

# Inputting the name and sales data for each sales person using a While Loop
i=1
while [[ $i -le $salespersons_count ]] ; do
   echo "$i"
  (( i += 1 ))

# Inputting the salesperson name
  echo "Enter the Name of the Salesperson"
  read name
# Inputting number of  A class Models sold by the respective salesperson
  echo "Enter the Number of A Class sold by " $name
  read A_class_sale
# Inputting number of  B class Models sold by the respective salesperson
  echo "Enter the Number of B Class sold by " $name
  read B_class_sale
# Inputting number of  C class Models sold by the respective salesperson
  echo "Enter the Number of C Class sold by " $name
  read C_class_sale
# Inputting number of  E class Models sold by the respective salesperson
  echo "Enter the Number of E Class sold by " $name
  read E_class_sale
# Inputting number of  AMG C65 sold by the respective salesperson
  echo "Enter the Number of AMG C65 Class sold by " $name
  read AMG_C65_sale

# Calculating the total amount of sale produced by the respective seller
  sale=$(((A_class_sale * A_class_cost) + (B_class_sale * B_class_cost) + (C_class_sale * C_class_cost) + (E_class_sale * E_class_cost) + (AMG_C65_sale * AMG_C65_cost)))

# Determining the Bonus received by the respective seller depending on the sale produced by him/her
  if [[ $sale -gt 650000 ]]
  then
  bonus=$((30000))
  elif [[ $sale -gt 500000 ]]
  then
  bonus=$((25000))
  elif [[ $sale -le 400000 ]]
  then
  bonus=$((20000))
  elif [[ $sale -gt 300000 ]]
  then
  bonus=$((15000))
  elif [[ $sale -gt 200000 ]]
  then
  bonus=$((10000))
  elif [[ $sale -lt 12500 ]]
  then
  bonus=$((0))
  fi

# Determining the payable TAX by the respective seller depending on his/her income
  if [[ $((basic_salary+bonus)) -gt 50000 ]]
  then
  tax=$((((basic_salary+bonus)/10)*4))
  elif [[ $((basic_salary+bonus)) -gt 12500 ]]
  then
  tax=$((((basic_salary+bonus)/10)*2))
  elif [[ $((basic_salary+bonus)) -le 12500 ]]
  then
  tax=$((0))
  fi
# Determining the net salary of the respective Sales-person
  net_pay=$((basic_salary+bonus-tax))

# Appending the data to arrays to manipulate it further
  Names+=("$name")
  netSalary+=($((net_pay)))
  grossSalary+=($((basic_salary+bonus)))

# End of Nested While Loops
done
done

# Another Nested While loops For BUBBLE SORT algorithm. It is done to sort the data with respect to Names
i=0
while [[ $i -le $((salespersons_count-1)) ]] ; do
  echo 'i' $i
  (( i += 1 ))
   j=0
while [[ $j -le $((salespersons_count-1)) ]] ; do
  echo 'j' $j
  (( j += 1 ))
# If statement to judge whether one name is greater than other for sorting
   if [[ "${Names[$i]}" >  "${Names[$j]}" ]]
  then
# Temporary variables to assist bubble sort
  tempName=${Names[$i]}
  tempGP=${grossSalary[$i]}
  tempNP=${netSalary[$i]}

  Names[$i]=${Names[$j]}
  netSalary[$i]=${netSalary[$j]}
  grossSalary[$i]=${grossSalary[$j]}

  Names[$j]=$tempName
  netSalary[$j]=$tempNP
  grossSalary[$j]=$tempGP
#  Outputting a message if its already sorted
  else
    echo sorted already
  fi
# End of Nested While Loops and End of BUBBLE SORT part
done
done

# checking that if path is provided or not
# If path not provided, we only use name. or otherwise, we add a slash between name and path
if [[ $path -gt "" ]]
then
myFile=$path'/'$file.txt
else
myFile=$file.txt
fi

# Outputting all data to the custom text file using a while loop
i=0
while [[ $i -le $((salespersons_count-1)) ]] ; do
   echo "${Names[$i]}" "${netSalary[$i]}" $month >> $myFile
   echo 'output ' $((i+1))
   echo "${Names[$i]}" "${netSalary[$i]}" $month
    (( i += 1 ))
done


