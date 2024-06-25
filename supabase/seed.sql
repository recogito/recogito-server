ALTER TABLE public.role_policies
DROP CONSTRAINT role_policies_policy_id_fkey;

TRUNCATE public.policies;

INSERT INTO
    public.policies (id, table_name, operation)
VALUES
    ('6717fdc0-45df-46f3-b7d3-0d4c4569a33a', 'annotations', 'SELECT'),
    ('557553f6-1ce4-44f1-a565-49e38a45b631', 'annotations', 'INSERT'),
    ('008dd3b9-a447-4f84-83e0-8143f0ba7454', 'annotations', 'UPDATE'),
    ('01c5435d-68ba-442a-a918-d9e0ff53b627', 'annotations', 'DELETE'),
    ('17733e9d-9135-424d-9b44-621bd66064a3', 'bodies', 'SELECT'),
    ('3650c340-2263-4df5-ae47-ae12ce32a2a8', 'bodies', 'INSERT'),
    ('e3276780-1806-400b-b0d4-60e0d617716f', 'bodies', 'UPDATE'),
    ('5d48fc5a-a7d0-4dce-837a-083bf793f716', 'bodies', 'DELETE'),
    ('8ffcf0ea-9b03-419a-ada9-a56e7033d317', 'contexts', 'SELECT'),
    ('f988018e-f8b3-4f17-8fb5-295beaa7e2d8', 'contexts', 'INSERT'),
    ('db188f97-0a65-4adf-8961-c475dcc3bdd7', 'contexts', 'UPDATE'),
    ('4b9a761e-1070-4f03-aa0f-b6d4231b8dff', 'contexts', 'DELETE'),
    ('864e3666-5aaf-4021-b6bb-785ed0714505', 'default_groups', 'SELECT'),
    ('256baf94-ca71-4598-bd29-1181cbe2ef76', 'default_groups', 'INSERT'),
    ('26a44be2-4db5-4784-ac40-ddfe69f8229d', 'default_groups', 'UPDATE'),
    ('6a48f187-2f09-468b-93e0-81627dbeacd6', 'default_groups', 'DELETE'),
    ('40c78f89-e227-4bfb-8b7d-5912dd054598', 'documents', 'SELECT'),
    ('3eca4407-a589-4301-b705-1deb54a05811', 'documents', 'INSERT'),
    ('a2cacc27-cd35-4851-a46a-df0d72cd3751', 'documents', 'UPDATE'),
    ('41d6338a-d95e-4e4a-81ce-8ccde043c64e', 'documents', 'DELETE'),
    ('b7d1724e-931c-4248-a793-d6cc1ce198f4', 'group_users', 'SELECT'),
    ('4c31d65f-07b5-4054-9015-41491973a844', 'group_users', 'INSERT'),
    ('9711f038-b4ec-41a6-94e6-25a3b4fcef74', 'group_users', 'UPDATE'),
    ('36bc2eca-0861-4a0e-85a1-042262d653dc', 'group_users', 'DELETE'),
    ('dbeae20d-f490-45f6-9de8-315e5f88b9a6', 'invites', 'SELECT'),
    ('dd203f6b-bc08-4a8e-b0fc-4a772b2f1d7a', 'invites', 'INSERT'),
    ('ec8ddded-418c-4078-9d67-31fc0ef17fce', 'invites', 'UPDATE'),
    ('0e486412-023d-42ff-b44f-04020c5a404d', 'invites', 'DELETE'),
    ('0050ab09-124e-40ea-b7ca-723fcc60c3ed', 'layer_contexts', 'SELECT'),
    ('194f2948-2932-4ef4-8047-b5be6311caeb', 'layer_contexts', 'INSERT'),
    ('a7ed0949-baba-442d-a670-ac6d9a254e4a', 'layer_contexts', 'UPDATE'),
    ('b72b28e1-d364-4707-a414-430f3b126a2b', 'layer_contexts', 'DELETE'),
    ('b3bb875a-4e63-41ca-94ec-71fd0f2bad33', 'layer_groups', 'SELECT'),
    ('6af8ceea-969c-4b1c-9a6c-49a27d2822a0', 'layer_groups', 'INSERT'),
    ('9c4c4720-8396-4d67-994c-f4f80cf65192', 'layer_groups', 'UPDATE'),
    ('1ccbb131-cd05-4157-a7ec-249e2211e7cd', 'layer_groups', 'DELETE'),
    ('a5f90d2c-51cd-468a-b304-7e5952025a4f', 'layers', 'SELECT'),
    ('94b8b59d-178d-4b50-9a25-6ee2dd900eae', 'layers', 'INSERT'),
    ('44502907-eb57-4313-89d7-8430d50bf5ea', 'layers', 'UPDATE'),
    ('ea68da56-4094-4108-afa1-b7dea3165a50', 'layers', 'DELETE'),
    ('1c7bf0a4-3284-4572-9884-e175701e5ad7', 'organization_groups', 'SELECT'),
    ('8ff0b01e-3684-4b45-bf0b-a89524a50266', 'organization_groups', 'INSERT'),
    ('a5426a8a-f621-4d2f-961a-3870a645c21e', 'organization_groups', 'UPDATE'),
    ('9cf05f8a-62fc-4d8a-8738-6139d684183e', 'organization_groups', 'DELETE'),
    ('75fc9f7d-26b0-438c-8ba8-c2d9b398a383', 'policies', 'SELECT'),
    ('8e3e17bd-2790-4efa-8ac7-0b2e37ba6bef', 'policies', 'INSERT'),
    ('8ef93e89-d4a9-4d14-8ee5-bbe5f3a9149c', 'policies', 'UPDATE'),
    ('060d2992-f0c8-49e7-a114-2f6d46a1cb00', 'policies', 'DELETE'),
    ('c3cd9930-1778-4320-90e9-447d5011a2ee', 'profiles', 'SELECT'),
    ('e6ce9c37-4411-4b11-84b7-a4499127ac75', 'profiles', 'INSERT'),
    ('50eb62af-c2d1-4b2f-a7f0-3a70b9fe3941', 'profiles', 'UPDATE'),
    ('89b86bf4-433b-44a1-954e-6bf8a5589bcf', 'profiles', 'DELETE'),
    ('b716be7a-81b6-4d0a-a55c-a7ca60352ef3', 'project_documents', 'SELECT'),
    ('037bd847-68e1-4e7a-bdce-aa50933dbc00', 'project_documents', 'INSERT'),
    ('10c417f5-603d-4bac-90f4-7365289adbc1', 'project_documents', 'UPDATE'),
    ('38411911-e90d-4b47-9d2b-39948be3e363', 'project_documents', 'DELETE'),
    ('1291126f-21e9-42a3-b56c-0a7e1227a3d6', 'project_groups', 'SELECT'),
    ('8ccf6d91-4c95-4cb6-965a-ca574dd2595c', 'project_groups', 'INSERT'),
    ('9abee578-76d5-408f-99b6-68ba8d3c9f2d', 'project_groups', 'UPDATE'),
    ('290eaefd-2605-47de-a934-4dbd518cb7e1', 'project_groups', 'DELETE'),
    ('ca44caef-cdeb-4ca8-bbc7-2421be779934', 'projects', 'SELECT'),
    ('b0e10840-0332-41e7-91c8-330842e023a0', 'projects', 'INSERT'),
    ('03163857-ff98-4989-bb6a-65304c58107c', 'projects', 'UPDATE'),
    ('a1077848-74cf-4c1d-87c7-96794646e7f4', 'projects', 'DELETE'),
    ('c6f16244-0737-4d6b-ae40-a02722784d8f', 'role_policies', 'SELECT'),
    ('c6ef76b2-f376-43d6-9001-edac1eb05523', 'role_policies', 'INSERT'),
    ('12ece44b-fca1-4975-9f1c-42f09212524b', 'role_policies', 'UPDATE'),
    ('60bd883f-4065-4df0-9bc7-ee37eb0f9fe3', 'role_policies', 'DELETE'),
    ('0f44d9fa-4648-4a33-85c0-cba64229d79e', 'roles', 'SELECT'),
    ('17968f3a-89b0-48c0-8b14-c49a044a8f64', 'roles', 'INSERT'),
    ('26800335-a066-49b3-8e33-c6cfd804585b', 'roles', 'UPDATE'),
    ('e2cd4fa2-df13-4d54-a3c6-fcd788d8702f', 'roles', 'DELETE'),
    ('7e830a72-19ac-4486-87a7-ca697f430fca', 'tag_definitions', 'SELECT'),
    ('73f9137b-d3b9-49e5-8e3f-f779070ad8f8', 'tag_definitions', 'INSERT'),
    ('fe40a2ef-bcae-441a-935a-eda090d0ac6d', 'tag_definitions', 'UPDATE'),
    ('8413d484-f01c-4aca-9972-0b9e0b7189fc', 'tag_definitions', 'DELETE'),
    ('2cb6d98c-14d8-44bd-a977-1ca1116fc44f', 'tags', 'SELECT'),
    ('b508e4ca-46bd-478c-9582-fa1c671aa03e', 'tags', 'INSERT'),
    ('6ec09042-5dc0-4593-b506-d4c57c3e14cd', 'tags', 'UPDATE'),
    ('1994c713-cf46-41da-be95-96dafbb55fe9', 'tags', 'DELETE'),
    ('1c1bb427-4f2f-40cb-ae03-6799199bbec8', 'targets', 'SELECT'),
    ('5648e0e9-3354-4b5c-b815-29d01d98a551', 'targets', 'INSERT'),
    ('45017da5-cb03-4826-ae6f-dafbe1e21339', 'targets', 'UPDATE'),
    ('9a7fb2a1-9ccb-4071-8ec9-b90fcf1eb546', 'targets', 'DELETE'),
    ('50c00273-d524-4d60-a9af-050d1cff51a3', 'collections', 'SELECT'),
    ('2b94630b-b725-4715-ba72-3388d3c63cbd', 'collections', 'INSERT'),
    ('0fdb8964-87a1-457b-bbcc-b6f05e44c695', 'collections', 'UPDATE'),
    ('3152390c-1764-4f4d-b6cd-98979c868286', 'collections', 'DELETE'),
    ('a4b82076-cf7d-4f7a-b24d-f12587d71590', 'context_documents', 'SELECT'),
    ('02e217c8-9409-4223-a118-ae0487ce4fa5', 'context_documents', 'INSERT'),
    ('28a43878-359f-4761-9a45-573fc7b593b1', 'context_documents', 'UPDATE'),
    ('80c7a2a2-79e7-4163-b53f-5583506021c1', 'context_documents', 'DELETE'),
    ('51eb3610-a7ee-4fd6-9a71-65214aee0dd7', 'context_users', 'SELECT'),
    ('3aa4d2bf-2127-4c66-8858-e9a6b59dbd07', 'context_users', 'INSERT'),
    ('0377daa4-38b3-459d-8715-999532af1cb1', 'context_users', 'UPDATE'),
    ('6a4fec4c-a1c3-4d20-8451-c6ecba886a82', 'context_users', 'DELETE'),     
    ('79cd967d-f268-4bb8-9e84-0eafeac3307f', 'installed_plugins', 'SELECT'),
    ('d651e790-2dc2-4522-b876-9f27af71c5f6', 'installed_plugins', 'INSERT'),
    ('0b7820da-aceb-442e-9a5d-3fb3fcaa5254', 'installed_plugins', 'UPDATE'),
    ('b92a5f03-ac77-4f0e-907a-873c9d2f78bf', 'installed_plugins', 'DELETE'),
    ('bebfe10f-5316-4ef0-8059-80050515ec5c', 'join_requests', 'SELECT'),
    ('9b85eef3-e174-4fbe-81e6-7f1d26adf748', 'join_requests', 'INSERT'),
    ('db0d70e3-7477-4926-bfc5-abc738149856', 'join_requests', 'UPDATE'),
    ('a5cc4271-bde2-4f6e-bd96-97fe790ab5ea', 'join_requests', 'DELETE');

ALTER TABLE public.role_policies
ADD CONSTRAINT role_policies_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies (id);

SET
    CLIENT_MIN_MESSAGES TO NOTICE;
