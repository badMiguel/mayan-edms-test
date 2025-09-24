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

    Set Metadata As Optional    ${new_metadata_type["id"]}

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

    ${new_label_1}=     Create String Length         49
    ${new_name}=        Create Unique String            Metadata_Type_Name
    ${resp}=            Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...                 Create Metadata Type Via API    ${new_label_1}    ${new_name}

    Should Contain     ${resp}  400

    ${new_label_2}=     Create String Length         48
    ${new_name}=        Create Unique String            Metadata_Type_Label
    ${resp}=            Create Metadata Type Via API    ${new_label_2}    ${new_name}

    Should Be Equal As Integers     ${resp.status_code}    201
    Set Metadata As Optional        ${resp.json()["id"]}

Create Metadata Type With Long Name Via API
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 API if name is greater than 48 characters.

    ${new_name_1}=      Create String Length         49
    ${new_label}=       Create Unique String            Metadata_Type_Name
    ${resp}=            Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...                 Create Metadata Type Via API    ${new_label}    ${new_name_1}

    Should Contain      ${resp}  400

    ${new_name_2}=      Create String Length         48
    ${new_label}=       Create Unique String            Metadata_Type_Label
    ${resp}=            Create Metadata Type Via API    ${new_label}    ${new_name_2}

    Should Be Equal As Integers     ${resp.status_code}    201
    Set Metadata As Optional        ${resp.json()["id"]}

Create Valid Metadata Type Via UI
    [Documentation]     Good Case. Create a metadata using the UI

    # Sleep a bit to avoid having same label generated from the previous test
    # `Create Metadata Type With Long Name Via API`
    Sleep    1s

    ${new_label}=   Create Unique String    Metadata_Type_Label
    ${new_name}=    Create Unique String    Metadata_Type_Name

    Create Metadata Type Via UI   ${new_label}  ${new_name}

    Wait Until Page Contains    Metadata type created successfully      10s
    Wait Until Page Contains    ${new_label}                            10s

    Wait For Metadata Type By Label To Exist In DB    ${new_label}
    Validate Metadata Type In DB Via Label            ${new_label}      ${new_name}

    ${rows}=    Get Metadata Type By Label  ${new_label}
    Set Metadata As Optional    ${rows[0][0]}

Create Metadata Type Without Label And Name Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 UI without label and name.

    Create Metadata Type Via UI     ${EMPTY}    ${EMPTY}
    ${is_valid}=    Execute Javascript    return document.getElementById('id_label').checkValidity();
    Should Not Be True        ${is_valid}
    ${is_valid}=    Execute Javascript    return document.getElementById('id_name').checkValidity();
    Should Not Be True        ${is_valid}

Create Metadata Type Without Label Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 UI without label.

    ${new_name}=    Create Unique String    Metadata_Type_Name
    Create Metadata Type Via UI     ${EMPTY}    ${new_name}
    ${is_valid}=    Execute Javascript    return document.getElementById('id_label').checkValidity();
    Should Not Be True        ${is_valid}

Create Metadata Type Without Name Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 UI without name.

    ${new_label}=    Create Unique String    Metadata_Type_Label
    Create Metadata Type Via UI     ${new_label}    ${EMPTY}
    ${is_valid}=    Execute Javascript    return document.getElementById('id_name').checkValidity();
    Should Not Be True        ${is_valid}

Create Duplicate Metadata Type Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new metadata type via
    ...                 UI with existing name

    ${new_label}=   Create Unique String    Metadata_Type_Label
    Create Metadata Type Via UI     ${new_label}    ${new_metadata_type_name}
    Wait Until Page Contains        Metadata type with this Name already exists.    10s
