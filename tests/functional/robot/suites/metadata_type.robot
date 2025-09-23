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

    ${new_metadata_type_label}=    Create Unique String     Metadata_Type_Label
    Set Global Variable            ${new_metadata_type_label}
    ${new_metadata_type_name}=     Create Unique String     Metadata_Type_Name
    Set Global Variable            ${new_metadata_type_name}

    ${resp}=                    Create Metadata Type Via API          ${new_metadata_type_label}    ${new_metadata_type_name}
    ${new_metadata_type}=       Set Variable    ${resp.json()}     
    Set Global Variable         ${new_metadata_type}

    Should Be Equal As Integers     ${resp.status_code}                 201
    Dictionary Should Contain Key   ${new_metadata_type}                id
    Should Be Equal                 ${new_metadata_type["label"]}       ${new_metadata_type_label}
    Should Be Equal                 ${new_metadata_type["name"]}        ${new_metadata_type_name}
    
    Wait For Metadata Type By ID To Exist In DB    ${new_metadata_type["id"]}
    Validate Metadata Type In DB Via ID    ${new_metadata_type["id"]}     ${new_metadata_type_label}     ${new_metadata_type_name}

Create Metadata Type Without Label And Name Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata 
    ...                 type via API if no label and name is specified 

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Metadata Type Via API    ${EMPTY}    ${EMPTY}

    Should Contain    ${resp}    400

Create Metadata Type Without Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata 
    ...                 type via API if no label is specified 

    ${new_name}=   Create Unique String    Metadata_Type_Name
    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Metadata Type Via API    ${EMPTY}    ${new_name}

    Should Contain    ${resp}    400

Create Metadata Type Without Name Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata 
    ...                 type via API if no name is specified 

    ${new_label}=   Create Unique String    Metadata_Type_Label
    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Metadata Type Via API    ${new_label}    ${EMPTY}

    Should Contain    ${resp}    400

Create Metadata Type With Existing Name Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata
    ...                 type via API if specified NAME already exists. 

    ${new_label}=   Create Unique String        Metadata_Type_Label
    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Metadata Type Via API    ${new_metadata_type_label}      ${new_metadata_type_name}  

    Should Contain    ${resp}    400

Create Metadata Type With Long Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 API if label is greater than 48 characters.

    ${new_label_1}=     Create Very Long String         49
    ${new_name}=        Create Unique String            Metadata_Type_Name
    ${resp}=            Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...                 Create Metadata Type Via API    ${new_label_1}    ${new_name}

    Should Contain     ${resp}  400

    ${new_label_2}=     Create Very Long String         48
    ${new_name}=        Create Unique String            Metadata_Type_Label
    ${resp}=            Create Metadata Type Via API    ${new_label_2}    ${new_name}

    Should Be Equal As Integers     ${resp.status_code}    201

Create Metadata Type With Long Name Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 API if name is greater than 48 characters.

Create Metadata Type Via UI
    No Operation

Create Metadata Type Without Label And Name Via UI
    No Operation

Create Metadata Type Without Label Via UI
    No Operation

Create Metadata Type Without Name Via UI
    No Operation

Create Duplicate Metadata Type Via UI
    No Operation

Create Metadata Type With Long Label Via UI
    No Operation

Create Metadata Type With Long Name Via UI
    No Operation
