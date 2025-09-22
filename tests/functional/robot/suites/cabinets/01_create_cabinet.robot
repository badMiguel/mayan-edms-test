*** Settings ***
Documentation   Tests create cabinet functionality

Resource    ../../resources/variables.resource
Resource    ../../resources/keywords/common.resource
Resource    ../../resources/keywords/cabinet.resource
Library    Collections

*** Test Cases ***
Create Parent Cabinet Successfully
    [Documentation]     Good Case. Successfully create a new parent cabinet
    ...                 (no parent field specified).

    ${new_parent_cabinet_label}=    Create Unique Label     Robot_Cabinet
    Set Global Variable             ${new_parent_cabinet_label}

    ${cabinet}=     Create Cabinet Via API  ${new_parent_cabinet_label}  

    Dictionary Should Contain Key   ${cabinet}              id
    Should Be Equal                 ${cabinet["label"]}     ${new_parent_cabinet_label}

# Create Duplicate Parent Cabinet Should Fail
#     [Documentation]     Bad Case. Should NOT be able to create a new parent 
#     ...                 cabinet if specified label already exists.
#
#     ${cabinet}=     Create Cabinet Via API  ${new_parent_cabinet_label}  
#     Dictionary Should Contain Key   ${cabinet}              id
#     Should Not Be Equal             ${cabinet["label"]}     ${new_parent_cabinet_label}

    Dictionary Should Contain Key       ${cabinet}              id
    Should Be Equal                     ${cabinet["label"]}     ${LABEL}
