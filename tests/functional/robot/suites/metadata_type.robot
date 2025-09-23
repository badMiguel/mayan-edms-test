*** Settings ***
Documentation   Tests create metadata functionality

Resource    ../resources/variables.resource
Resource    ../resources/keywords/common.resource
Resource    ../resources/keywords/metadata_type.resource
Library     Collections

*** Test Cases ***
Create Valid Metadata Type Via API
    [Documentation]     Good Case. Successfully create a new metadata type via
    ...                 API.

    ${new_metadata_type_label}=    Create Unique Label     Metadata_Type_Label
    Set Global Variable            ${new_metadata_type_label}
    ${new_metadata_type_name}=     Create Unique Label     Metadata_Type_Name
    Set Global Variable            ${new_metadata_type_name}

    ${resp}=                    Create Metadata Type Via API          ${new_metadata_type_label}    ${new_metadata_type_name}
    ${new_metadata_type}=       Set Variable    ${resp.json()}     
    Set Global Variable         ${new_metadata_type}

    Should Be Equal As Integers     ${resp.status_code}                 201
    Dictionary Should Contain Key   ${new_metadata_type}                id
    Should Be Equal                 ${new_metadata_type["label"]}       ${new_metadata_type_label}
    Should Be Equal                 ${new_metadata_type["name"]}        ${new_metadata_type_name}
    
    # Wait For Cabinet By ID To Exist In DB    ${new_metadata_type["id"]}
    # Validate Cabinet In DB Via ID    ${new_metadata_type["id"]}    ${new_metadata_type["label"]}
