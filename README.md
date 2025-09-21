# A - Ingestion & Classification

1. Document Upload
2. Metadata & Tagging
3. Cabinets / Taxonomy (foldering)
4. Bulk Operations (bulk tag/metadata/move)

> [!NOTE]
>
> - Seeds test data (cabinets/tags/metadata) used by others. Optional: 4 OCR (initiation on upload).
> - B, C, D depend on A to create cabinets/tags/seed docs.
> - B can validate OCR searchability after A triggers OCR on upload.
> - D permission tests require the cabinets from A

## APIs related to task A

### Authorisation

- /api/v4/auth/token/obtain/?format=json
    - POST: get auth token

### Batch Request
- /api/v4/batch_requests/
    - POST: submit a batch request

### Cabinets

- /api/v4/cabinets/
    - GET: returns list of cabinets
    - POST: creates new cabinet
- /api/v4/cabinets/_cabinet_id_/
    - DELETE: delete cabinet
    - GET: details of selected cabinet
    - PUT/PATCH: edit selected cabinet
- /api/v4/cabinets/_cabinet_id_/documents/
    - GET: returns list of documents in selected cabinet

### Documents

- /api/v4/documents/
    - GET: returns list of documents
    - POST: create a new document
- /api/v4/documents/_document_id_/
    - DELETE: delete selected document
    - GET: returns details of selected document
    - PUT/PATCH: edit details of selected document

#### Files

- /api/v4/documents/_document_id_/files/
    - GET: returns files of selected document
    - POST: create new document file
    - _note: document can have multiple files_
- /api/v4/documents/_document_id_/files/_file_id_/
    - DELETE: delete selected file
    - GET: returns details of selected file
    - PUT/PATCH: edit details of selected file

#### Document Type

- /api/v4/documents/_document_id_/type/change/
    - POST: change type of selected document

#### Metadata

- /api/v4/documents/_document_id_/metadata/
    - GET: return list of metadata type and value of selected document
    - POST: add existing metadata type to selected document

> [!NOTE]
> make sure to configure metadata in document type to add metadata to document

#### Tags

- /api/v4/documents/_document_id_/tags/
    - GET: returns list of tags attached to document
- /api/v4/documents/_document_id_/tags/attach/
    - POST: attach tag to document

### Document File Actions
- /api/v4/document_file_actions/
    - GET: list all available document file actions

### Document Type

- /api/v4/document_types/
    - GET: return list of all document types
    - POST: create a new document type
- /api/v4/document_types/_document-type-id_/
    - DELETE: delete selected document type
    - GET: return document type details
    - PUT/PATCH: edit selected document type
- /api/v4/document_types/_document-type-id_/documents/
    - GET: return list of document in a document type
- /api/v4/document_types/_document-type-id_/metadata_types/
    - GET: return list of document type's metadata type
    - POST: add metadata type to document type

> [!NOTE]
> Document Type is responsible for document expiry

### Metadata Types

- /api/v4/metadata_types/
    - GET: returns list of all metadata types
    - POST: create new metadata type
- /api/v4/metadata_types/_metadata_type_id_/
    - DELETE: delete selected metadata type
    - GET: return details of metadata
    - PUT/PATCH: edit details of metadata

> [!NOTE]
> To view available options for creating a new metadata type, visit path
> /metadata/metadata_types/create/

### Tags

- /api/v4/tags/
    - GET: returns list of tags
    - POST: create a new tag
- /api/v4/tags/_tag_id_/
    - DELETE: delete selected tag
    - GET: returns details of selected tag
    - PUT/PATCH: edit selected tag
- /api/v4/tags/_tag_id_/documents/
    - GET: returns list of documents in a tag
