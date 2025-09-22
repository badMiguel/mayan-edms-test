*** Settings ***
Documentation   Tests create cabinet functionality

Resource    ../../resources/variables.resource
Resource    ../../resources/keywords/common.resource
Resource    ../../resources/keywords/cabinet.resource
Library    Collections

*** Variables ***
${LABEL}    ${EMPTY}

*** Test Cases ***
Create Parent Cabinet Successfully
    [Documentation]     Good Case. Successfully create a new parent cabinet
    ...                 (no parent field specified).

    ${LABEL}=       Create Unique Label     Robot_Cabinet
    ${cabinet}=     Create Cabinet Via API  ${LABEL}  

    Log To Console    ${cabinet}

    Dictionary Should Contain Key       ${cabinet}              id
    Should Be Equal                     ${cabinet["label"]}     ${LABEL}
