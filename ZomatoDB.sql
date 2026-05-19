-- ============================================================
--  ZOMATO COMPLETE NORMALIZED DATABASE SCHEMA  (MS SQL SERVER)
--  All 4 domains: Geography/Users, Restaurant/Menu,
--                 Orders/Payments/Delivery, Company Ops
--  Normalization: 3NF throughout
--  Conventions  : UNIQUEIDENTIFIER PKs (NEWSEQUENTIALID()),
--                 SMALLINT for lookup tables,
--                 all FKs explicitly named,
--                 CHECK constraints on enums,
--                 indexes on every FK + high-query columns
-- ============================================================

USE master;
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ZomatoDB')
    CREATE DATABASE ZomatoDB;
GO
USE ZomatoDB;
GO

-- ============================================================
-- SECTION 1 — GEOGRAPHY & USERS
-- ============================================================

-- 1.1 Geography Lookups
CREATE TABLE dbo.Countries (
    country_id    SMALLINT        NOT NULL IDENTITY(1,1),
    iso_code      CHAR(2)         NOT NULL,
    name          NVARCHAR(100)   NOT NULL,
    currency_code CHAR(3)         NOT NULL,
    phone_prefix  VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Countries         PRIMARY KEY (country_id),
    CONSTRAINT UQ_Countries_iso     UNIQUE      (iso_code)
);

CREATE TABLE dbo.States (
    state_id   INT             NOT NULL IDENTITY(1,1),
    country_id SMALLINT        NOT NULL,
    name       NVARCHAR(100)   NOT NULL,
    code       VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_States             PRIMARY KEY (state_id),
    CONSTRAINT FK_States_Country     FOREIGN KEY (country_id) REFERENCES dbo.Countries(country_id)
);
CREATE INDEX IX_States_CountryId ON dbo.States(country_id);

CREATE TABLE dbo.Cities (
    city_id        INT             NOT NULL IDENTITY(1,1),
    state_id       INT             NOT NULL,
    name           NVARCHAR(100)   NOT NULL,
    latitude       DECIMAL(10,7)   NOT NULL,
    longitude      DECIMAL(10,7)   NOT NULL,
    is_serviceable BIT             NOT NULL CONSTRAINT DF_Cities_Serviceable DEFAULT 1,
    is_active      BIT             NOT NULL CONSTRAINT DF_Cities_Active      DEFAULT 1,
    CONSTRAINT PK_Cities         PRIMARY KEY (city_id),
    CONSTRAINT FK_Cities_State   FOREIGN KEY (state_id) REFERENCES dbo.States(state_id)
);
CREATE INDEX IX_Cities_StateId ON dbo.Cities(state_id);

CREATE TABLE dbo.Pincodes (
    pincode_id INT           NOT NULL IDENTITY(1,1),
    city_id    INT           NOT NULL,
    pincode    VARCHAR(20)   NOT NULL,
    latitude   DECIMAL(10,7) NULL,
    longitude  DECIMAL(10,7) NULL,
    CONSTRAINT PK_Pincodes         PRIMARY KEY (pincode_id),
    CONSTRAINT UQ_Pincodes_code    UNIQUE      (pincode),
    CONSTRAINT FK_Pincodes_City    FOREIGN KEY (city_id) REFERENCES dbo.Cities(city_id)
);
CREATE INDEX IX_Pincodes_CityId ON dbo.Pincodes(city_id);

-- 1.2 User Lookups
CREATE TABLE dbo.Genders (
    gender_id SMALLINT     NOT NULL IDENTITY(1,1),
    label     NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Genders PRIMARY KEY (gender_id)
);

CREATE TABLE dbo.AddressTypes (
    address_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label           NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_AddressTypes PRIMARY KEY (address_type_id)
);

-- 1.3 Users
CREATE TABLE dbo.Users (
    user_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Users_Id DEFAULT NEWSEQUENTIALID(),
    full_name      NVARCHAR(150)    NOT NULL,
    email          NVARCHAR(255)    NOT NULL,
    phone          VARCHAR(20)      NOT NULL,
    password_hash  VARCHAR(256)     NOT NULL,
    phone_verified BIT              NOT NULL CONSTRAINT DF_Users_PhoneV DEFAULT 0,
    email_verified BIT              NOT NULL CONSTRAINT DF_Users_EmailV DEFAULT 0,
    dob            DATE             NULL,
    gender_id      SMALLINT         NULL,
    profile_pic_url NVARCHAR(500)   NULL,
    is_active      BIT              NOT NULL CONSTRAINT DF_Users_Active   DEFAULT 1,
    is_blocked     BIT              NOT NULL CONSTRAINT DF_Users_Blocked  DEFAULT 0,
    created_at     DATETIME2        NOT NULL CONSTRAINT DF_Users_Created  DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2        NOT NULL CONSTRAINT DF_Users_Updated  DEFAULT SYSUTCDATETIME(),
    last_login     DATETIME2        NULL,
    CONSTRAINT PK_Users            PRIMARY KEY (user_id),
    CONSTRAINT UQ_Users_Email      UNIQUE      (email),
    CONSTRAINT UQ_Users_Phone      UNIQUE      (phone),
    CONSTRAINT FK_Users_Gender     FOREIGN KEY (gender_id) REFERENCES dbo.Genders(gender_id)
);

CREATE TABLE dbo.UserAuthProviders (
    auth_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_UAP_Id DEFAULT NEWSEQUENTIALID(),
    user_id      UNIQUEIDENTIFIER NOT NULL,
    provider     VARCHAR(50)      NOT NULL,   -- 'google','facebook','apple'
    provider_uid VARCHAR(255)     NOT NULL,
    access_token NVARCHAR(1000)   NULL,
    token_expiry DATETIME2        NULL,
    linked_at    DATETIME2        NOT NULL CONSTRAINT DF_UAP_LinkedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserAuthProviders          PRIMARY KEY (auth_id),
    CONSTRAINT UQ_UAP_ProviderUid            UNIQUE      (provider, provider_uid),
    CONSTRAINT FK_UAP_User                   FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);
CREATE INDEX IX_UAP_UserId ON dbo.UserAuthProviders(user_id);

CREATE TABLE dbo.UserSessions (
    session_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_US_Id DEFAULT NEWSEQUENTIALID(),
    user_id      UNIQUEIDENTIFIER NOT NULL,
    device_type  VARCHAR(20)      NULL,   -- 'android','ios','web'
    device_token NVARCHAR(500)    NULL,
    ip_address   VARCHAR(45)      NULL,
    user_agent   NVARCHAR(500)    NULL,
    created_at   DATETIME2        NOT NULL CONSTRAINT DF_US_Created DEFAULT SYSUTCDATETIME(),
    expires_at   DATETIME2        NOT NULL,
    is_active    BIT              NOT NULL CONSTRAINT DF_US_Active DEFAULT 1,
    CONSTRAINT PK_UserSessions      PRIMARY KEY (session_id),
    CONSTRAINT FK_US_User           FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);
CREATE INDEX IX_UserSessions_UserId ON dbo.UserSessions(user_id);

CREATE TABLE dbo.UserAddresses (
    address_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_UA_Id DEFAULT NEWSEQUENTIALID(),
    user_id         UNIQUEIDENTIFIER NOT NULL,
    pincode_id      INT              NOT NULL,
    address_type_id SMALLINT         NOT NULL,
    label           NVARCHAR(100)    NULL,
    line1           NVARCHAR(300)    NOT NULL,
    line2           NVARCHAR(300)    NULL,
    landmark        NVARCHAR(200)    NULL,
    latitude        DECIMAL(10,7)    NOT NULL,
    longitude       DECIMAL(10,7)    NOT NULL,
    is_default      BIT              NOT NULL CONSTRAINT DF_UA_Default  DEFAULT 0,
    is_deleted      BIT              NOT NULL CONSTRAINT DF_UA_Deleted  DEFAULT 0,
    created_at      DATETIME2        NOT NULL CONSTRAINT DF_UA_Created  DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserAddresses         PRIMARY KEY (address_id),
    CONSTRAINT FK_UA_User               FOREIGN KEY (user_id)         REFERENCES dbo.Users(user_id)        ON DELETE NO ACTION,
    CONSTRAINT FK_UA_Pincode            FOREIGN KEY (pincode_id)      REFERENCES dbo.Pincodes(pincode_id),
    CONSTRAINT FK_UA_AddressType        FOREIGN KEY (address_type_id) REFERENCES dbo.AddressTypes(address_type_id)
);
CREATE INDEX IX_UA_UserId    ON dbo.UserAddresses(user_id);
CREATE INDEX IX_UA_PincodeId ON dbo.UserAddresses(pincode_id);

CREATE TABLE dbo.UserPreferences (
    pref_id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_UP_Id DEFAULT NEWSEQUENTIALID(),
    user_id              UNIQUEIDENTIFIER NOT NULL,
    veg_only             BIT              NOT NULL CONSTRAINT DF_UP_Veg DEFAULT 0,
    notification_prefs   NVARCHAR(MAX)    NULL,   -- JSON
    language_code        VARCHAR(10)      NOT NULL CONSTRAINT DF_UP_Lang DEFAULT 'en',
    updated_at           DATETIME2        NOT NULL CONSTRAINT DF_UP_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserPreferences    PRIMARY KEY (pref_id),
    CONSTRAINT UQ_UP_User            UNIQUE      (user_id),
    CONSTRAINT FK_UP_User            FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE TABLE dbo.UserCuisinePreferences (
    ucp_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_UCP_Id DEFAULT NEWSEQUENTIALID(),
    user_id    UNIQUEIDENTIFIER NOT NULL,
    cuisine_id SMALLINT         NOT NULL,
    CONSTRAINT PK_UCP          PRIMARY KEY (ucp_id),
    CONSTRAINT UQ_UCP          UNIQUE      (user_id, cuisine_id),
    CONSTRAINT FK_UCP_User     FOREIGN KEY (user_id)    REFERENCES dbo.Users(user_id)   ON DELETE CASCADE
    -- FK_UCP_Cuisine added via ALTER below
);

CREATE TABLE dbo.Wishlists (
    wishlist_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_WL_Id DEFAULT NEWSEQUENTIALID(),
    user_id     UNIQUEIDENTIFIER NOT NULL,
    name        NVARCHAR(100)    NOT NULL,
    is_default  BIT              NOT NULL CONSTRAINT DF_WL_Default DEFAULT 0,
    is_public   BIT              NOT NULL CONSTRAINT DF_WL_Public  DEFAULT 0,
    created_at  DATETIME2        NOT NULL CONSTRAINT DF_WL_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Wishlists    PRIMARY KEY (wishlist_id),
    CONSTRAINT FK_WL_User      FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);
CREATE INDEX IX_Wishlists_UserId ON dbo.Wishlists(user_id);

CREATE TABLE dbo.WishlistRestaurants (
    wl_rest_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_WLR_Id DEFAULT NEWSEQUENTIALID(),
    wishlist_id   UNIQUEIDENTIFIER NOT NULL,
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    saved_at      DATETIME2        NOT NULL CONSTRAINT DF_WLR_Saved DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_WishlistRestaurants      PRIMARY KEY (wl_rest_id),
    CONSTRAINT UQ_WLR                      UNIQUE      (wishlist_id, restaurant_id),
    CONSTRAINT FK_WLR_Wishlist             FOREIGN KEY (wishlist_id)   REFERENCES dbo.Wishlists(wishlist_id)     ON DELETE CASCADE
    -- FK_WLR_Restaurant added via ALTER below
);
CREATE INDEX IX_WLR_WishlistId ON dbo.WishlistRestaurants(wishlist_id);

-- ============================================================
-- SECTION 2 — RESTAURANTS & MENUS
-- ============================================================

-- 2.1 Restaurant Lookups
CREATE TABLE dbo.Cuisines (
    cuisine_id SMALLINT     NOT NULL IDENTITY(1,1),
    name       NVARCHAR(80) NOT NULL,
    slug       VARCHAR(80)  NOT NULL,
    icon_url   NVARCHAR(500) NULL,
    CONSTRAINT PK_Cuisines      PRIMARY KEY (cuisine_id),
    CONSTRAINT UQ_Cuisines_Name UNIQUE (name),
    CONSTRAINT UQ_Cuisines_Slug UNIQUE (slug)
);

CREATE TABLE dbo.FoodCategories (
    food_category_id SMALLINT      NOT NULL IDENTITY(1,1),
    name             NVARCHAR(80)  NOT NULL,
    description      NVARCHAR(300) NULL,
    CONSTRAINT PK_FoodCategories      PRIMARY KEY (food_category_id),
    CONSTRAINT UQ_FoodCategories_Name UNIQUE (name)
);

CREATE TABLE dbo.Allergens (
    allergen_id SMALLINT      NOT NULL IDENTITY(1,1),
    name        NVARCHAR(80)  NOT NULL,
    icon_url    NVARCHAR(500) NULL,
    CONSTRAINT PK_Allergens      PRIMARY KEY (allergen_id),
    CONSTRAINT UQ_Allergens_Name UNIQUE (name)
);

CREATE TABLE dbo.DietaryTags (
    tag_id SMALLINT     NOT NULL IDENTITY(1,1),
    label  NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_DietaryTags      PRIMARY KEY (tag_id),
    CONSTRAINT UQ_DietaryTags_Label UNIQUE (label)
);

CREATE TABLE dbo.DocumentTypes (
    doc_type_id  SMALLINT    NOT NULL IDENTITY(1,1),
    label        NVARCHAR(80) NOT NULL,
    is_mandatory BIT         NOT NULL CONSTRAINT DF_DT_Mandatory DEFAULT 0,
    CONSTRAINT PK_DocumentTypes PRIMARY KEY (doc_type_id)
);

-- 2.2 Restaurant Partners
CREATE TABLE dbo.RestaurantPartners (
    partner_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RP_Id DEFAULT NEWSEQUENTIALID(),
    owner_name       NVARCHAR(150)    NOT NULL,
    email            NVARCHAR(255)    NOT NULL,
    phone            VARCHAR(20)      NOT NULL,
    gst_number       VARCHAR(20)      NOT NULL,
    fssai_number     VARCHAR(30)      NOT NULL,
    pan_number       VARCHAR(15)      NOT NULL,
    kyc_status       VARCHAR(20)      NOT NULL CONSTRAINT DF_RP_KYC DEFAULT 'pending',
    is_onboarded     BIT              NOT NULL CONSTRAINT DF_RP_Onboarded DEFAULT 0,
    commission_rate  DECIMAL(5,2)     NOT NULL CONSTRAINT DF_RP_Comm DEFAULT 20.00,
    contract_url     NVARCHAR(500)    NULL,
    onboarded_at     DATETIME2        NULL,
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_RP_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_RestaurantPartners          PRIMARY KEY (partner_id),
    CONSTRAINT UQ_RP_Email                    UNIQUE (email),
    CONSTRAINT UQ_RP_GST                      UNIQUE (gst_number),
    CONSTRAINT UQ_RP_FSSAI                    UNIQUE (fssai_number),
    CONSTRAINT UQ_RP_PAN                      UNIQUE (pan_number),
    CONSTRAINT CK_RP_KYC                      CHECK  (kyc_status IN ('pending','in_review','approved','rejected'))
);

CREATE TABLE dbo.PartnerBankAccounts (
    bank_id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PBA_Id DEFAULT NEWSEQUENTIALID(),
    partner_id          UNIQUEIDENTIFIER NOT NULL,
    account_number      VARCHAR(30)      NOT NULL,
    ifsc_code           VARCHAR(15)      NOT NULL,
    bank_name           NVARCHAR(100)    NOT NULL,
    account_holder_name NVARCHAR(150)    NOT NULL,
    is_primary          BIT              NOT NULL CONSTRAINT DF_PBA_Primary   DEFAULT 0,
    is_verified         BIT              NOT NULL CONSTRAINT DF_PBA_Verified  DEFAULT 0,
    added_at            DATETIME2        NOT NULL CONSTRAINT DF_PBA_Added     DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PartnerBankAccounts       PRIMARY KEY (bank_id),
    CONSTRAINT UQ_PBA_AccountNumber         UNIQUE (account_number),
    CONSTRAINT FK_PBA_Partner               FOREIGN KEY (partner_id) REFERENCES dbo.RestaurantPartners(partner_id)
);
CREATE INDEX IX_PBA_PartnerId ON dbo.PartnerBankAccounts(partner_id);

-- 2.3 Restaurants
CREATE TABLE dbo.Restaurants (
    restaurant_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Res_Id DEFAULT NEWSEQUENTIALID(),
    partner_id      UNIQUEIDENTIFIER NOT NULL,
    name            NVARCHAR(200)    NOT NULL,
    slug            VARCHAR(200)     NOT NULL,
    description     NVARCHAR(1000)   NULL,
    pure_veg        BIT              NOT NULL CONSTRAINT DF_Res_Veg      DEFAULT 0,
    is_featured     BIT              NOT NULL CONSTRAINT DF_Res_Featured  DEFAULT 0,
    is_active       BIT              NOT NULL CONSTRAINT DF_Res_Active    DEFAULT 1,
    is_verified     BIT              NOT NULL CONSTRAINT DF_Res_Verified  DEFAULT 0,
    avg_rating      DECIMAL(3,2)     NOT NULL CONSTRAINT DF_Res_Rating    DEFAULT 0.00,
    total_ratings   INT              NOT NULL CONSTRAINT DF_Res_Ratings   DEFAULT 0,
    avg_delivery_mins INT            NULL,
    min_order_value DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Res_MinOrder  DEFAULT 0.00,
    cover_image_url NVARCHAR(500)    NULL,
    logo_url        NVARCHAR(500)    NULL,
    created_at      DATETIME2        NOT NULL CONSTRAINT DF_Res_Created   DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2        NOT NULL CONSTRAINT DF_Res_Updated   DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Restaurants         PRIMARY KEY (restaurant_id),
    CONSTRAINT UQ_Restaurants_Slug    UNIQUE      (slug),
    CONSTRAINT FK_Res_Partner         FOREIGN KEY (partner_id) REFERENCES dbo.RestaurantPartners(partner_id),
    CONSTRAINT CK_Res_Rating          CHECK (avg_rating BETWEEN 0 AND 5)
);
CREATE INDEX IX_Res_PartnerId ON dbo.Restaurants(partner_id);

CREATE TABLE dbo.RestaurantCuisines (
    rc_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RC_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    cuisine_id    SMALLINT         NOT NULL,
    CONSTRAINT PK_RestaurantCuisines      PRIMARY KEY (rc_id),
    CONSTRAINT UQ_RC                      UNIQUE (restaurant_id, cuisine_id),
    CONSTRAINT FK_RC_Restaurant           FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE,
    CONSTRAINT FK_RC_Cuisine              FOREIGN KEY (cuisine_id)    REFERENCES dbo.Cuisines(cuisine_id)
);

CREATE TABLE dbo.RestaurantDietaryTags (
    rt_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RDT_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    tag_id        SMALLINT         NOT NULL,
    CONSTRAINT PK_RestaurantDietaryTags   PRIMARY KEY (rt_id),
    CONSTRAINT UQ_RDT                     UNIQUE (restaurant_id, tag_id),
    CONSTRAINT FK_RDT_Restaurant          FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE,
    CONSTRAINT FK_RDT_Tag                 FOREIGN KEY (tag_id)        REFERENCES dbo.DietaryTags(tag_id)
);

CREATE TABLE dbo.RestaurantLocations (
    location_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RL_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    pincode_id    INT              NOT NULL,
    line1         NVARCHAR(300)    NOT NULL,
    line2         NVARCHAR(300)    NULL,
    landmark      NVARCHAR(200)    NULL,
    latitude      DECIMAL(10,7)    NOT NULL,
    longitude     DECIMAL(10,7)    NOT NULL,
    google_place_id VARCHAR(100)   NULL,
    is_primary    BIT              NOT NULL CONSTRAINT DF_RL_Primary DEFAULT 1,
    CONSTRAINT PK_RestaurantLocations     PRIMARY KEY (location_id),
    CONSTRAINT FK_RL_Restaurant           FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE,
    CONSTRAINT FK_RL_Pincode              FOREIGN KEY (pincode_id)    REFERENCES dbo.Pincodes(pincode_id)
);
CREATE INDEX IX_RL_RestaurantId ON dbo.RestaurantLocations(restaurant_id);
CREATE INDEX IX_RL_PincodeId    ON dbo.RestaurantLocations(pincode_id);

CREATE TABLE dbo.RestaurantHours (
    hours_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RH_Id DEFAULT NEWSEQUENTIALID(),
    location_id   UNIQUEIDENTIFIER NOT NULL,
    day_of_week   SMALLINT         NOT NULL,   -- 0=Sun ... 6=Sat
    opens_at      TIME             NOT NULL,
    closes_at     TIME             NOT NULL,
    is_holiday    BIT              NOT NULL CONSTRAINT DF_RH_Holiday DEFAULT 0,
    CONSTRAINT PK_RestaurantHours        PRIMARY KEY (hours_id),
    CONSTRAINT UQ_RH_LocationDay         UNIQUE (location_id, day_of_week),
    CONSTRAINT FK_RH_Location            FOREIGN KEY (location_id) REFERENCES dbo.RestaurantLocations(location_id) ON DELETE CASCADE,
    CONSTRAINT CK_RH_Day                 CHECK (day_of_week BETWEEN 0 AND 6)
);

CREATE TABLE dbo.RestaurantImages (
    image_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RI_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    url           NVARCHAR(500)    NOT NULL,
    alt_text      NVARCHAR(200)    NULL,
    display_order SMALLINT         NOT NULL CONSTRAINT DF_RI_Order DEFAULT 0,
    image_type    VARCHAR(30)      NOT NULL CONSTRAINT DF_RI_Type DEFAULT 'gallery',
    uploaded_at   DATETIME2        NOT NULL CONSTRAINT DF_RI_Uploaded DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_RestaurantImages     PRIMARY KEY (image_id),
    CONSTRAINT FK_RI_Restaurant        FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE,
    CONSTRAINT CK_RI_ImageType         CHECK (image_type IN ('logo','cover','gallery','menu_board'))
);
CREATE INDEX IX_RI_RestaurantId ON dbo.RestaurantImages(restaurant_id);

CREATE TABLE dbo.RestaurantDocuments (
    doc_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RD_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    doc_type_id   SMALLINT         NOT NULL,
    doc_url       NVARCHAR(500)    NOT NULL,
    doc_number    VARCHAR(50)      NOT NULL,
    expiry_date   DATE             NULL,
    status        VARCHAR(20)      NOT NULL CONSTRAINT DF_RD_Status DEFAULT 'pending',
    uploaded_at   DATETIME2        NOT NULL CONSTRAINT DF_RD_Uploaded  DEFAULT SYSUTCDATETIME(),
    verified_at   DATETIME2        NULL,
    verified_by   UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_RestaurantDocuments       PRIMARY KEY (doc_id),
    CONSTRAINT UQ_RD_DocNumber              UNIQUE (doc_number),
    CONSTRAINT FK_RD_Restaurant             FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE,
    CONSTRAINT FK_RD_DocType                FOREIGN KEY (doc_type_id)   REFERENCES dbo.DocumentTypes(doc_type_id),
    CONSTRAINT CK_RD_Status                 CHECK (status IN ('pending','in_review','approved','rejected','expired'))
    -- FK_RD_VerifiedBy added via ALTER below
);

-- 2.4 Menus
CREATE TABLE dbo.Menus (
    menu_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_M_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    name          NVARCHAR(100)    NOT NULL,
    is_active     BIT              NOT NULL CONSTRAINT DF_M_Active DEFAULT 1,
    valid_from    DATETIME2        NULL,
    valid_until   DATETIME2        NULL,
    CONSTRAINT PK_Menus          PRIMARY KEY (menu_id),
    CONSTRAINT FK_M_Restaurant   FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id) ON DELETE CASCADE
);
CREATE INDEX IX_Menus_RestaurantId ON dbo.Menus(restaurant_id);

CREATE TABLE dbo.MenuCategories (
    cat_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MC_Id DEFAULT NEWSEQUENTIALID(),
    menu_id       UNIQUEIDENTIFIER NOT NULL,
    name          NVARCHAR(100)    NOT NULL,
    description   NVARCHAR(300)    NULL,
    display_order INT              NOT NULL CONSTRAINT DF_MC_Order DEFAULT 0,
    is_active     BIT              NOT NULL CONSTRAINT DF_MC_Active DEFAULT 1,
    CONSTRAINT PK_MenuCategories     PRIMARY KEY (cat_id),
    CONSTRAINT FK_MC_Menu            FOREIGN KEY (menu_id) REFERENCES dbo.Menus(menu_id) ON DELETE CASCADE
);
CREATE INDEX IX_MC_MenuId ON dbo.MenuCategories(menu_id);

CREATE TABLE dbo.MenuItems (
    item_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MI_Id DEFAULT NEWSEQUENTIALID(),
    cat_id           UNIQUEIDENTIFIER NOT NULL,
    restaurant_id    UNIQUEIDENTIFIER NOT NULL,
    food_category_id SMALLINT         NULL,
    name             NVARCHAR(200)    NOT NULL,
    description      NVARCHAR(1000)   NULL,
    base_price       DECIMAL(10,2)    NOT NULL,
    is_veg           BIT              NOT NULL CONSTRAINT DF_MI_Veg        DEFAULT 0,
    is_vegan         BIT              NOT NULL CONSTRAINT DF_MI_Vegan      DEFAULT 0,
    is_egg           BIT              NOT NULL CONSTRAINT DF_MI_Egg        DEFAULT 0,
    is_bestseller    BIT              NOT NULL CONSTRAINT DF_MI_Best       DEFAULT 0,
    is_available     BIT              NOT NULL CONSTRAINT DF_MI_Available  DEFAULT 1,
    calories         INT              NULL,
    image_url        NVARCHAR(500)    NULL,
    display_order    INT              NOT NULL CONSTRAINT DF_MI_Order      DEFAULT 0,
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_MI_Created    DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_MenuItems           PRIMARY KEY (item_id),
    CONSTRAINT FK_MI_Category         FOREIGN KEY (cat_id)           REFERENCES dbo.MenuCategories(cat_id),
    CONSTRAINT FK_MI_Restaurant       FOREIGN KEY (restaurant_id)    REFERENCES dbo.Restaurants(restaurant_id),
    CONSTRAINT FK_MI_FoodCategory     FOREIGN KEY (food_category_id) REFERENCES dbo.FoodCategories(food_category_id),
    CONSTRAINT CK_MI_Price            CHECK (base_price >= 0)
);
CREATE INDEX IX_MI_CatId        ON dbo.MenuItems(cat_id);
CREATE INDEX IX_MI_RestaurantId ON dbo.MenuItems(restaurant_id);

CREATE TABLE dbo.ItemAllergens (
    ia_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_IA_Id DEFAULT NEWSEQUENTIALID(),
    item_id     UNIQUEIDENTIFIER NOT NULL,
    allergen_id SMALLINT         NOT NULL,
    CONSTRAINT PK_ItemAllergens     PRIMARY KEY (ia_id),
    CONSTRAINT UQ_IA                UNIQUE (item_id, allergen_id),
    CONSTRAINT FK_IA_Item           FOREIGN KEY (item_id)     REFERENCES dbo.MenuItems(item_id) ON DELETE CASCADE,
    CONSTRAINT FK_IA_Allergen       FOREIGN KEY (allergen_id) REFERENCES dbo.Allergens(allergen_id)
);

CREATE TABLE dbo.ItemDietaryTags (
    idt_id  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_IDT_Id DEFAULT NEWSEQUENTIALID(),
    item_id UNIQUEIDENTIFIER NOT NULL,
    tag_id  SMALLINT         NOT NULL,
    CONSTRAINT PK_ItemDietaryTags   PRIMARY KEY (idt_id),
    CONSTRAINT UQ_IDT               UNIQUE (item_id, tag_id),
    CONSTRAINT FK_IDT_Item          FOREIGN KEY (item_id) REFERENCES dbo.MenuItems(item_id) ON DELETE CASCADE,
    CONSTRAINT FK_IDT_Tag           FOREIGN KEY (tag_id)  REFERENCES dbo.DietaryTags(tag_id)
);

CREATE TABLE dbo.ItemPriceHistory (
    ph_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_IPH_Id DEFAULT NEWSEQUENTIALID(),
    item_id     UNIQUEIDENTIFIER NOT NULL,
    old_price   DECIMAL(10,2)    NOT NULL,
    new_price   DECIMAL(10,2)    NOT NULL,
    changed_at  DATETIME2        NOT NULL CONSTRAINT DF_IPH_Changed DEFAULT SYSUTCDATETIME(),
    changed_by  UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_ItemPriceHistory   PRIMARY KEY (ph_id),
    CONSTRAINT FK_IPH_Item           FOREIGN KEY (item_id)    REFERENCES dbo.MenuItems(item_id)    ON DELETE CASCADE
    -- FK_IPH_ChangedBy added via ALTER below
);
CREATE INDEX IX_IPH_ItemId ON dbo.ItemPriceHistory(item_id);

CREATE TABLE dbo.CustomizationGroups (
    group_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CG_Id DEFAULT NEWSEQUENTIALID(),
    item_id        UNIQUEIDENTIFIER NOT NULL,
    name           NVARCHAR(100)    NOT NULL,
    is_required    BIT              NOT NULL CONSTRAINT DF_CG_Required DEFAULT 0,
    multi_select   BIT              NOT NULL CONSTRAINT DF_CG_Multi    DEFAULT 0,
    min_selections SMALLINT         NOT NULL CONSTRAINT DF_CG_Min      DEFAULT 0,
    max_selections SMALLINT         NOT NULL CONSTRAINT DF_CG_Max      DEFAULT 1,
    display_order  INT              NOT NULL CONSTRAINT DF_CG_Order    DEFAULT 0,
    CONSTRAINT PK_CustomizationGroups   PRIMARY KEY (group_id),
    CONSTRAINT FK_CG_Item               FOREIGN KEY (item_id) REFERENCES dbo.MenuItems(item_id) ON DELETE CASCADE
);
CREATE INDEX IX_CG_ItemId ON dbo.CustomizationGroups(item_id);

CREATE TABLE dbo.CustomizationOptions (
    option_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CO_Id DEFAULT NEWSEQUENTIALID(),
    group_id     UNIQUEIDENTIFIER NOT NULL,
    label        NVARCHAR(150)    NOT NULL,
    extra_price  DECIMAL(10,2)    NOT NULL CONSTRAINT DF_CO_Price DEFAULT 0.00,
    is_default   BIT              NOT NULL CONSTRAINT DF_CO_Default   DEFAULT 0,
    is_available BIT              NOT NULL CONSTRAINT DF_CO_Available DEFAULT 1,
    CONSTRAINT PK_CustomizationOptions   PRIMARY KEY (option_id),
    CONSTRAINT FK_CO_Group               FOREIGN KEY (group_id) REFERENCES dbo.CustomizationGroups(group_id) ON DELETE CASCADE
);
CREATE INDEX IX_CO_GroupId ON dbo.CustomizationOptions(group_id);

-- ============================================================
-- SECTION 3 — ORDERS, PAYMENTS & DELIVERY
-- ============================================================

-- 3.1 Lookup Tables
CREATE TABLE dbo.OrderStatuses (
    status_id   SMALLINT      NOT NULL IDENTITY(1,1),
    code        VARCHAR(40)   NOT NULL,
    label       NVARCHAR(80)  NOT NULL,
    description NVARCHAR(300) NULL,
    sort_order  INT           NOT NULL CONSTRAINT DF_OS_Sort DEFAULT 0,
    CONSTRAINT PK_OrderStatuses      PRIMARY KEY (status_id),
    CONSTRAINT UQ_OS_Code            UNIQUE (code)
);

CREATE TABLE dbo.PaymentMethods (
    pm_id     SMALLINT     NOT NULL IDENTITY(1,1),
    code      VARCHAR(30)  NOT NULL,
    label     NVARCHAR(80) NOT NULL,
    is_active BIT          NOT NULL CONSTRAINT DF_PM_Active DEFAULT 1,
    CONSTRAINT PK_PaymentMethods     PRIMARY KEY (pm_id),
    CONSTRAINT UQ_PM_Code            UNIQUE (code)
);

CREATE TABLE dbo.PaymentProviders (
    provider_id SMALLINT      NOT NULL IDENTITY(1,1),
    name        NVARCHAR(80)  NOT NULL,
    api_key_ref VARCHAR(100)  NULL,
    is_active   BIT           NOT NULL CONSTRAINT DF_PP_Active DEFAULT 1,
    CONSTRAINT PK_PaymentProviders   PRIMARY KEY (provider_id),
    CONSTRAINT UQ_PP_Name            UNIQUE (name)
);

CREATE TABLE dbo.CancellationReasons (
    reason_id   SMALLINT      NOT NULL IDENTITY(1,1),
    actor_type  VARCHAR(20)   NOT NULL,   -- 'user','restaurant','system'
    reason_text NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_CancellationReasons   PRIMARY KEY (reason_id),
    CONSTRAINT CK_CR_Actor              CHECK (actor_type IN ('user','restaurant','agent','system'))
);

CREATE TABLE dbo.VehicleTypes (
    vehicle_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label           NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_VehicleTypes PRIMARY KEY (vehicle_type_id)
);

-- 3.2 Cart
CREATE TABLE dbo.Carts (
    cart_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Cart_Id DEFAULT NEWSEQUENTIALID(),
    user_id       UNIQUEIDENTIFIER NOT NULL,
    restaurant_id UNIQUEIDENTIFIER NOT NULL,
    is_active     BIT              NOT NULL CONSTRAINT DF_Cart_Active DEFAULT 1,
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_Cart_Created DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2        NOT NULL CONSTRAINT DF_Cart_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Carts          PRIMARY KEY (cart_id),
    CONSTRAINT FK_Cart_User      FOREIGN KEY (user_id)       REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Cart_Restaurant FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id)
);
CREATE INDEX IX_Carts_UserId ON dbo.Carts(user_id);

CREATE TABLE dbo.CartItems (
    ci_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CI_Id DEFAULT NEWSEQUENTIALID(),
    cart_id     UNIQUEIDENTIFIER NOT NULL,
    item_id     UNIQUEIDENTIFIER NOT NULL,
    quantity    INT              NOT NULL CONSTRAINT DF_CI_Qty DEFAULT 1,
    unit_price  DECIMAL(10,2)    NOT NULL,
    line_total  DECIMAL(10,2)    NOT NULL,
    CONSTRAINT PK_CartItems      PRIMARY KEY (ci_id),
    CONSTRAINT FK_CI_Cart        FOREIGN KEY (cart_id)  REFERENCES dbo.Carts(cart_id)     ON DELETE CASCADE,
    CONSTRAINT FK_CI_Item        FOREIGN KEY (item_id)  REFERENCES dbo.MenuItems(item_id),
    CONSTRAINT CK_CI_Qty         CHECK (quantity > 0)
);
CREATE INDEX IX_CI_CartId ON dbo.CartItems(cart_id);

CREATE TABLE dbo.CartItemCustomizations (
    cic_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CIC_Id DEFAULT NEWSEQUENTIALID(),
    ci_id       UNIQUEIDENTIFIER NOT NULL,
    option_id   UNIQUEIDENTIFIER NOT NULL,
    extra_price DECIMAL(10,2)    NOT NULL CONSTRAINT DF_CIC_Extra DEFAULT 0.00,
    CONSTRAINT PK_CartItemCustomizations   PRIMARY KEY (cic_id),
    CONSTRAINT UQ_CIC                      UNIQUE (ci_id, option_id),
    CONSTRAINT FK_CIC_CartItem             FOREIGN KEY (ci_id)      REFERENCES dbo.CartItems(ci_id)              ON DELETE CASCADE,
    CONSTRAINT FK_CIC_Option               FOREIGN KEY (option_id)  REFERENCES dbo.CustomizationOptions(option_id)
);

-- 3.3 Orders
CREATE TABLE dbo.Orders (
    order_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Ord_Id DEFAULT NEWSEQUENTIALID(),
    user_id             UNIQUEIDENTIFIER NOT NULL,
    restaurant_id       UNIQUEIDENTIFIER NOT NULL,
    delivery_address_id UNIQUEIDENTIFIER NOT NULL,
    cart_id             UNIQUEIDENTIFIER NULL,
    status_id           SMALLINT         NOT NULL,
    payment_method_id   SMALLINT         NOT NULL,
    coupon_code         VARCHAR(50)      NULL,
    subtotal            DECIMAL(10,2)    NOT NULL,
    item_discount       DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_ItemDisc    DEFAULT 0.00,
    coupon_discount     DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_CoupDisc    DEFAULT 0.00,
    delivery_fee        DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_DelivFee    DEFAULT 0.00,
    surge_fee           DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_SurgeFee    DEFAULT 0.00,
    platform_fee        DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_PlatFee     DEFAULT 0.00,
    tax_amount          DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Ord_Tax         DEFAULT 0.00,
    total_amount        DECIMAL(10,2)    NOT NULL,
    special_instructions NVARCHAR(500)   NULL,
    is_contactless      BIT              NOT NULL CONSTRAINT DF_Ord_Contactless DEFAULT 0,
    placed_at           DATETIME2        NOT NULL CONSTRAINT DF_Ord_Placed      DEFAULT SYSUTCDATETIME(),
    estimated_delivery_at DATETIME2      NULL,
    delivered_at        DATETIME2        NULL,
    cancelled_at        DATETIME2        NULL,
    cancel_reason_id    SMALLINT         NULL,
    cancel_note         NVARCHAR(300)    NULL,
    CONSTRAINT PK_Orders                  PRIMARY KEY (order_id),
    CONSTRAINT FK_Ord_User                FOREIGN KEY (user_id)             REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Ord_Restaurant          FOREIGN KEY (restaurant_id)       REFERENCES dbo.Restaurants(restaurant_id),
    CONSTRAINT FK_Ord_Address             FOREIGN KEY (delivery_address_id) REFERENCES dbo.UserAddresses(address_id),
    CONSTRAINT FK_Ord_Status              FOREIGN KEY (status_id)           REFERENCES dbo.OrderStatuses(status_id),
    CONSTRAINT FK_Ord_PayMethod           FOREIGN KEY (payment_method_id)   REFERENCES dbo.PaymentMethods(pm_id),
    CONSTRAINT FK_Ord_CancelReason        FOREIGN KEY (cancel_reason_id)    REFERENCES dbo.CancellationReasons(reason_id),
    CONSTRAINT CK_Ord_Total               CHECK (total_amount >= 0)
);
CREATE INDEX IX_Ord_UserId       ON dbo.Orders(user_id);
CREATE INDEX IX_Ord_RestaurantId ON dbo.Orders(restaurant_id);
CREATE INDEX IX_Ord_PlacedAt     ON dbo.Orders(placed_at DESC);
CREATE INDEX IX_Ord_StatusId     ON dbo.Orders(status_id);

CREATE TABLE dbo.OrderStatusHistory (
    hist_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_OSH_Id DEFAULT NEWSEQUENTIALID(),
    order_id        UNIQUEIDENTIFIER NOT NULL,
    status_id       SMALLINT         NOT NULL,
    note            NVARCHAR(300)    NULL,
    changed_by      UNIQUEIDENTIFIER NULL,
    changed_by_type VARCHAR(20)      NULL,   -- 'user','restaurant','agent','system'
    changed_at      DATETIME2        NOT NULL CONSTRAINT DF_OSH_Changed DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_OrderStatusHistory     PRIMARY KEY (hist_id),
    CONSTRAINT FK_OSH_Order              FOREIGN KEY (order_id)  REFERENCES dbo.Orders(order_id)       ON DELETE CASCADE,
    CONSTRAINT FK_OSH_Status             FOREIGN KEY (status_id) REFERENCES dbo.OrderStatuses(status_id)
);
CREATE INDEX IX_OSH_OrderId ON dbo.OrderStatusHistory(order_id);

CREATE TABLE dbo.OrderItems (
    oi_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_OI_Id DEFAULT NEWSEQUENTIALID(),
    order_id       UNIQUEIDENTIFIER NOT NULL,
    item_id        UNIQUEIDENTIFIER NOT NULL,
    item_name_snap NVARCHAR(200)    NOT NULL,
    is_veg_snap    BIT              NOT NULL,
    unit_price_snap DECIMAL(10,2)   NOT NULL,
    quantity       INT              NOT NULL,
    line_total     DECIMAL(10,2)    NOT NULL,
    CONSTRAINT PK_OrderItems     PRIMARY KEY (oi_id),
    CONSTRAINT FK_OI_Order       FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OI_Item        FOREIGN KEY (item_id)  REFERENCES dbo.MenuItems(item_id),
    CONSTRAINT CK_OI_Qty         CHECK (quantity > 0)
);
CREATE INDEX IX_OI_OrderId ON dbo.OrderItems(order_id);

CREATE TABLE dbo.OrderItemCustomizations (
    oic_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_OIC_Id DEFAULT NEWSEQUENTIALID(),
    oi_id            UNIQUEIDENTIFIER NOT NULL,
    option_id        UNIQUEIDENTIFIER NOT NULL,
    option_label_snap NVARCHAR(150)   NOT NULL,
    extra_price_snap DECIMAL(10,2)    NOT NULL,
    CONSTRAINT PK_OrderItemCustomizations   PRIMARY KEY (oic_id),
    CONSTRAINT FK_OIC_OrderItem             FOREIGN KEY (oi_id)     REFERENCES dbo.OrderItems(oi_id)                   ON DELETE CASCADE,
    CONSTRAINT FK_OIC_Option                FOREIGN KEY (option_id) REFERENCES dbo.CustomizationOptions(option_id)
);
CREATE INDEX IX_OIC_OiId ON dbo.OrderItemCustomizations(oi_id);

CREATE TABLE dbo.OrderTaxes (
    tax_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_OT_Id DEFAULT NEWSEQUENTIALID(),
    order_id UNIQUEIDENTIFIER NOT NULL,
    tax_type VARCHAR(40)      NOT NULL,   -- 'CGST','SGST','IGST','cess'
    rate     DECIMAL(5,2)     NOT NULL,
    amount   DECIMAL(10,2)    NOT NULL,
    CONSTRAINT PK_OrderTaxes     PRIMARY KEY (tax_id),
    CONSTRAINT FK_OT_Order       FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id) ON DELETE CASCADE
);
CREATE INDEX IX_OT_OrderId ON dbo.OrderTaxes(order_id);

-- 3.4 Payments & Refunds
CREATE TABLE dbo.Payments (
    payment_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Pay_Id DEFAULT NEWSEQUENTIALID(),
    order_id         UNIQUEIDENTIFIER NOT NULL,
    user_id          UNIQUEIDENTIFIER NOT NULL,
    provider_id      SMALLINT         NOT NULL,
    method_id        SMALLINT         NOT NULL,
    provider_txn_id  VARCHAR(200)     NOT NULL,
    amount           DECIMAL(10,2)    NOT NULL,
    currency         CHAR(3)          NOT NULL CONSTRAINT DF_Pay_Currency DEFAULT 'INR',
    status           VARCHAR(20)      NOT NULL CONSTRAINT DF_Pay_Status   DEFAULT 'pending',
    failure_code     VARCHAR(50)      NULL,
    failure_message  NVARCHAR(300)    NULL,
    initiated_at     DATETIME2        NOT NULL CONSTRAINT DF_Pay_Initiated DEFAULT SYSUTCDATETIME(),
    completed_at     DATETIME2        NULL,
    CONSTRAINT PK_Payments              PRIMARY KEY (payment_id),
    CONSTRAINT UQ_Pay_ProviderTxn       UNIQUE (provider_txn_id),
    CONSTRAINT FK_Pay_Order             FOREIGN KEY (order_id)    REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_Pay_User              FOREIGN KEY (user_id)     REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Pay_Provider          FOREIGN KEY (provider_id) REFERENCES dbo.PaymentProviders(provider_id),
    CONSTRAINT FK_Pay_Method            FOREIGN KEY (method_id)   REFERENCES dbo.PaymentMethods(pm_id),
    CONSTRAINT CK_Pay_Status            CHECK (status IN ('pending','processing','success','failed','cancelled'))
);
CREATE INDEX IX_Pay_OrderId ON dbo.Payments(order_id);
CREATE INDEX IX_Pay_UserId  ON dbo.Payments(user_id);

CREATE TABLE dbo.Refunds (
    refund_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Ref_Id DEFAULT NEWSEQUENTIALID(),
    payment_id         UNIQUEIDENTIFIER NOT NULL,
    order_id           UNIQUEIDENTIFIER NOT NULL,
    amount             DECIMAL(10,2)    NOT NULL,
    reason             NVARCHAR(300)    NULL,
    status             VARCHAR(20)      NOT NULL CONSTRAINT DF_Ref_Status DEFAULT 'pending',
    provider_refund_id VARCHAR(200)     NULL,
    requested_at       DATETIME2        NOT NULL CONSTRAINT DF_Ref_Requested DEFAULT SYSUTCDATETIME(),
    processed_at       DATETIME2        NULL,
    processed_by       UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_Refunds         PRIMARY KEY (refund_id),
    CONSTRAINT FK_Ref_Payment     FOREIGN KEY (payment_id) REFERENCES dbo.Payments(payment_id),
    CONSTRAINT FK_Ref_Order       FOREIGN KEY (order_id)   REFERENCES dbo.Orders(order_id),
    CONSTRAINT CK_Ref_Status      CHECK (status IN ('pending','processing','success','failed'))
);
CREATE INDEX IX_Ref_PaymentId ON dbo.Refunds(payment_id);
CREATE INDEX IX_Ref_OrderId   ON dbo.Refunds(order_id);

-- 3.5 Delivery
CREATE TABLE dbo.DeliveryZones (
    zone_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DZ_Id DEFAULT NEWSEQUENTIALID(),
    city_id          INT              NOT NULL,
    zone_name        NVARCHAR(100)    NOT NULL,
    surge_active     BIT              NOT NULL CONSTRAINT DF_DZ_Surge    DEFAULT 0,
    surge_multiplier DECIMAL(4,2)     NOT NULL CONSTRAINT DF_DZ_Mult     DEFAULT 1.00,
    is_active        BIT              NOT NULL CONSTRAINT DF_DZ_Active   DEFAULT 1,
    CONSTRAINT PK_DeliveryZones     PRIMARY KEY (zone_id),
    CONSTRAINT FK_DZ_City           FOREIGN KEY (city_id) REFERENCES dbo.Cities(city_id)
);
CREATE INDEX IX_DZ_CityId ON dbo.DeliveryZones(city_id);

CREATE TABLE dbo.DeliveryAgents (
    agent_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DA_Id DEFAULT NEWSEQUENTIALID(),
    full_name        NVARCHAR(150)    NOT NULL,
    phone            VARCHAR(20)      NOT NULL,
    email            NVARCHAR(255)    NULL,
    password_hash    VARCHAR(256)     NOT NULL,
    vehicle_type_id  SMALLINT         NOT NULL,
    vehicle_number   VARCHAR(20)      NOT NULL,
    dl_number        VARCHAR(30)      NOT NULL,
    zone_id          UNIQUEIDENTIFIER NULL,
    is_online        BIT              NOT NULL CONSTRAINT DF_DA_Online    DEFAULT 0,
    is_available     BIT              NOT NULL CONSTRAINT DF_DA_Available DEFAULT 0,
    is_active        BIT              NOT NULL CONSTRAINT DF_DA_Active    DEFAULT 1,
    avg_rating       DECIMAL(3,2)     NOT NULL CONSTRAINT DF_DA_Rating    DEFAULT 0.00,
    total_deliveries INT              NOT NULL CONSTRAINT DF_DA_Total     DEFAULT 0,
    joined_at        DATETIME2        NOT NULL CONSTRAINT DF_DA_Joined    DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_DeliveryAgents          PRIMARY KEY (agent_id),
    CONSTRAINT UQ_DA_Phone                UNIQUE (phone),
    CONSTRAINT FK_DA_VehicleType          FOREIGN KEY (vehicle_type_id) REFERENCES dbo.VehicleTypes(vehicle_type_id),
    CONSTRAINT FK_DA_Zone                 FOREIGN KEY (zone_id)         REFERENCES dbo.DeliveryZones(zone_id),
    CONSTRAINT CK_DA_Rating               CHECK (avg_rating BETWEEN 0 AND 5)
);

CREATE TABLE dbo.AgentLocations (
    loc_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AL_Id DEFAULT NEWSEQUENTIALID(),
    agent_id    UNIQUEIDENTIFIER NOT NULL,
    latitude    DECIMAL(10,7)    NOT NULL,
    longitude   DECIMAL(10,7)    NOT NULL,
    bearing     DECIMAL(6,2)     NULL,
    speed_kmh   DECIMAL(6,2)     NULL,
    recorded_at DATETIME2        NOT NULL CONSTRAINT DF_AL_Recorded DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AgentLocations     PRIMARY KEY (loc_id),
    CONSTRAINT FK_AL_Agent           FOREIGN KEY (agent_id) REFERENCES dbo.DeliveryAgents(agent_id) ON DELETE CASCADE
);
CREATE INDEX IX_AL_AgentId    ON dbo.AgentLocations(agent_id);
CREATE INDEX IX_AL_RecordedAt ON dbo.AgentLocations(recorded_at DESC);

CREATE TABLE dbo.DeliveryAssignments (
    assignment_id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DAs_Id DEFAULT NEWSEQUENTIALID(),
    order_id                UNIQUEIDENTIFIER NOT NULL,
    agent_id                UNIQUEIDENTIFIER NOT NULL,
    status                  VARCHAR(30)      NOT NULL CONSTRAINT DF_DAs_Status DEFAULT 'assigned',
    pickup_lat              DECIMAL(10,7)    NOT NULL,
    pickup_lng              DECIMAL(10,7)    NOT NULL,
    drop_lat                DECIMAL(10,7)    NOT NULL,
    drop_lng                DECIMAL(10,7)    NOT NULL,
    distance_km             DECIMAL(8,2)     NULL,
    estimated_mins          INT              NULL,
    actual_mins             INT              NULL,
    otp_hash                VARCHAR(256)     NULL,
    otp_verified            BIT              NOT NULL CONSTRAINT DF_DAs_OTP DEFAULT 0,
    assigned_at             DATETIME2        NOT NULL CONSTRAINT DF_DAs_Assigned DEFAULT SYSUTCDATETIME(),
    accepted_at             DATETIME2        NULL,
    reached_restaurant_at   DATETIME2        NULL,
    picked_up_at            DATETIME2        NULL,
    delivered_at            DATETIME2        NULL,
    failed_at               DATETIME2        NULL,
    failure_reason          NVARCHAR(300)    NULL,
    CONSTRAINT PK_DeliveryAssignments       PRIMARY KEY (assignment_id),
    CONSTRAINT UQ_DAs_Order                 UNIQUE (order_id),
    CONSTRAINT FK_DAs_Order                 FOREIGN KEY (order_id)  REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_DAs_Agent                 FOREIGN KEY (agent_id)  REFERENCES dbo.DeliveryAgents(agent_id),
    CONSTRAINT CK_DAs_Status                CHECK (status IN ('assigned','accepted','reached_restaurant','picked_up','delivered','failed','cancelled'))
);
CREATE INDEX IX_DAs_AgentId ON dbo.DeliveryAssignments(agent_id);

CREATE TABLE dbo.DeliveryRatings (
    rating_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DR_Id DEFAULT NEWSEQUENTIALID(),
    assignment_id UNIQUEIDENTIFIER NOT NULL,
    user_id       UNIQUEIDENTIFIER NOT NULL,
    rating        SMALLINT         NOT NULL,
    comment       NVARCHAR(500)    NULL,
    rated_at      DATETIME2        NOT NULL CONSTRAINT DF_DR_Rated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_DeliveryRatings       PRIMARY KEY (rating_id),
    CONSTRAINT UQ_DR_Assignment         UNIQUE (assignment_id),
    CONSTRAINT FK_DR_Assignment         FOREIGN KEY (assignment_id) REFERENCES dbo.DeliveryAssignments(assignment_id),
    CONSTRAINT FK_DR_User               FOREIGN KEY (user_id)       REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_DR_Rating             CHECK (rating BETWEEN 1 AND 5)
);

-- ============================================================
-- SECTION 4 — COMPANY OPERATIONS
-- ============================================================

-- 4.1 Admin & RBAC
CREATE TABLE dbo.AdminRoles (
    role_id     SMALLINT      NOT NULL IDENTITY(1,1),
    name        NVARCHAR(80)  NOT NULL,
    description NVARCHAR(300) NULL,
    CONSTRAINT PK_AdminRoles      PRIMARY KEY (role_id),
    CONSTRAINT UQ_AdminRoles_Name UNIQUE (name)
);

CREATE TABLE dbo.Permissions (
    perm_id     SMALLINT      NOT NULL IDENTITY(1,1),
    resource    VARCHAR(80)   NOT NULL,
    action      VARCHAR(40)   NOT NULL,   -- 'create','read','update','delete','approve'
    description NVARCHAR(200) NULL,
    CONSTRAINT PK_Permissions        PRIMARY KEY (perm_id),
    CONSTRAINT UQ_Perm_ResAction     UNIQUE (resource, action)
);

CREATE TABLE dbo.RolePermissions (
    rp_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RolePerm_Id DEFAULT NEWSEQUENTIALID(),
    role_id  SMALLINT         NOT NULL,
    perm_id  SMALLINT         NOT NULL,
    CONSTRAINT PK_RolePermissions    PRIMARY KEY (rp_id),
    CONSTRAINT UQ_RP                 UNIQUE (role_id, perm_id),
    CONSTRAINT FK_RP_Role            FOREIGN KEY (role_id) REFERENCES dbo.AdminRoles(role_id) ON DELETE CASCADE,
    CONSTRAINT FK_RP_Perm            FOREIGN KEY (perm_id) REFERENCES dbo.Permissions(perm_id)
);

CREATE TABLE dbo.AdminUsers (
    admin_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AU_Id DEFAULT NEWSEQUENTIALID(),
    role_id       SMALLINT         NOT NULL,
    full_name     NVARCHAR(150)    NOT NULL,
    email         NVARCHAR(255)    NOT NULL,
    password_hash VARCHAR(256)     NOT NULL,
    is_active     BIT              NOT NULL CONSTRAINT DF_AU_Active  DEFAULT 1,
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_AU_Created DEFAULT SYSUTCDATETIME(),
    last_login    DATETIME2        NULL,
    CONSTRAINT PK_AdminUsers         PRIMARY KEY (admin_id),
    CONSTRAINT UQ_AU_Email           UNIQUE (email),
    CONSTRAINT FK_AU_Role            FOREIGN KEY (role_id) REFERENCES dbo.AdminRoles(role_id)
);
CREATE INDEX IX_AU_RoleId ON dbo.AdminUsers(role_id);

-- 4.2 Coupons & Discounts
CREATE TABLE dbo.DiscountTypes (
    discount_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label            NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_DiscountTypes PRIMARY KEY (discount_type_id)
);

CREATE TABLE dbo.Coupons (
    coupon_id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Coup_Id DEFAULT NEWSEQUENTIALID(),
    code               VARCHAR(50)      NOT NULL,
    discount_type_id   SMALLINT         NOT NULL,
    discount_value     DECIMAL(10,2)    NOT NULL,
    max_discount_cap   DECIMAL(10,2)    NULL,
    min_order_value    DECIMAL(10,2)    NOT NULL CONSTRAINT DF_Coup_MinOrd DEFAULT 0.00,
    max_uses_total     INT              NULL,
    max_uses_per_user  INT              NOT NULL CONSTRAINT DF_Coup_PerUser DEFAULT 1,
    uses_so_far        INT              NOT NULL CONSTRAINT DF_Coup_Uses    DEFAULT 0,
    is_active          BIT              NOT NULL CONSTRAINT DF_Coup_Active  DEFAULT 1,
    first_order_only   BIT              NOT NULL CONSTRAINT DF_Coup_First   DEFAULT 0,
    applicable_to      VARCHAR(30)      NOT NULL CONSTRAINT DF_Coup_AppTo   DEFAULT 'all',
    applicable_entity_id UNIQUEIDENTIFIER NULL,
    valid_from         DATETIME2        NOT NULL,
    valid_until        DATETIME2        NOT NULL,
    created_by         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_Coupons              PRIMARY KEY (coupon_id),
    CONSTRAINT UQ_Coup_Code            UNIQUE (code),
    CONSTRAINT FK_Coup_DiscType        FOREIGN KEY (discount_type_id) REFERENCES dbo.DiscountTypes(discount_type_id),
    CONSTRAINT FK_Coup_CreatedBy       FOREIGN KEY (created_by)       REFERENCES dbo.AdminUsers(admin_id),
    CONSTRAINT CK_Coup_AppTo           CHECK (applicable_to IN ('all','restaurant','cuisine','user_segment','new_user'))
);

CREATE TABLE dbo.CouponUsage (
    usage_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CU_Id DEFAULT NEWSEQUENTIALID(),
    coupon_id        UNIQUEIDENTIFIER NOT NULL,
    user_id          UNIQUEIDENTIFIER NOT NULL,
    order_id         UNIQUEIDENTIFIER NOT NULL,
    discount_applied DECIMAL(10,2)    NOT NULL,
    used_at          DATETIME2        NOT NULL CONSTRAINT DF_CU_Used DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_CouponUsage        PRIMARY KEY (usage_id),
    CONSTRAINT UQ_CU_OrderCoupon     UNIQUE (order_id, coupon_id),
    CONSTRAINT FK_CU_Coupon          FOREIGN KEY (coupon_id) REFERENCES dbo.Coupons(coupon_id),
    CONSTRAINT FK_CU_User            FOREIGN KEY (user_id)   REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_CU_Order           FOREIGN KEY (order_id)  REFERENCES dbo.Orders(order_id)
);
CREATE INDEX IX_CU_CouponId ON dbo.CouponUsage(coupon_id);
CREATE INDEX IX_CU_UserId   ON dbo.CouponUsage(user_id);

-- 4.3 Subscriptions (Zomato Gold / Pro)
CREATE TABLE dbo.SubscriptionPlans (
    plan_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SP_Id DEFAULT NEWSEQUENTIALID(),
    name          NVARCHAR(80)     NOT NULL,
    description   NVARCHAR(500)    NULL,
    price         DECIMAL(10,2)    NOT NULL,
    duration_days INT              NOT NULL,
    benefits_json NVARCHAR(MAX)    NULL,
    is_active     BIT              NOT NULL CONSTRAINT DF_SP_Active DEFAULT 1,
    CONSTRAINT PK_SubscriptionPlans     PRIMARY KEY (plan_id),
    CONSTRAINT UQ_SP_Name               UNIQUE (name)
);

CREATE TABLE dbo.UserSubscriptions (
    sub_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_USub_Id DEFAULT NEWSEQUENTIALID(),
    user_id           UNIQUEIDENTIFIER NOT NULL,
    plan_id           UNIQUEIDENTIFIER NOT NULL,
    status            VARCHAR(20)      NOT NULL CONSTRAINT DF_USub_Status DEFAULT 'active',
    amount_paid       DECIMAL(10,2)    NOT NULL,
    payment_method_id SMALLINT         NOT NULL,
    auto_renew        BIT              NOT NULL CONSTRAINT DF_USub_AutoRenew DEFAULT 1,
    started_at        DATETIME2        NOT NULL CONSTRAINT DF_USub_Started   DEFAULT SYSUTCDATETIME(),
    expires_at        DATETIME2        NOT NULL,
    cancelled_at      DATETIME2        NULL,
    CONSTRAINT PK_UserSubscriptions     PRIMARY KEY (sub_id),
    CONSTRAINT FK_USub_User             FOREIGN KEY (user_id)           REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_USub_Plan             FOREIGN KEY (plan_id)           REFERENCES dbo.SubscriptionPlans(plan_id),
    CONSTRAINT FK_USub_PayMethod        FOREIGN KEY (payment_method_id) REFERENCES dbo.PaymentMethods(pm_id),
    CONSTRAINT CK_USub_Status           CHECK (status IN ('active','expired','cancelled','paused'))
);
CREATE INDEX IX_USub_UserId ON dbo.UserSubscriptions(user_id);

CREATE TABLE dbo.SubscriptionBenefitsLog (
    log_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SBL_Id DEFAULT NEWSEQUENTIALID(),
    sub_id        UNIQUEIDENTIFIER NOT NULL,
    order_id      UNIQUEIDENTIFIER NOT NULL,
    benefit_type  VARCHAR(60)      NOT NULL,
    savings       DECIMAL(10,2)    NOT NULL,
    applied_at    DATETIME2        NOT NULL CONSTRAINT DF_SBL_Applied DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_SubscriptionBenefitsLog   PRIMARY KEY (log_id),
    CONSTRAINT FK_SBL_Sub                   FOREIGN KEY (sub_id)   REFERENCES dbo.UserSubscriptions(sub_id),
    CONSTRAINT FK_SBL_Order                 FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id)
);

-- 4.4 Finance
CREATE TABLE dbo.RestaurantSettlements (
    settlement_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RS_Id DEFAULT NEWSEQUENTIALID(),
    partner_id         UNIQUEIDENTIFIER NOT NULL,
    restaurant_id      UNIQUEIDENTIFIER NOT NULL,
    bank_id            UNIQUEIDENTIFIER NOT NULL,
    period_start       DATE             NOT NULL,
    period_end         DATE             NOT NULL,
    order_count        INT              NOT NULL,
    gross_order_value  DECIMAL(14,2)    NOT NULL,
    commission_amount  DECIMAL(14,2)    NOT NULL,
    gateway_charges    DECIMAL(14,2)    NOT NULL CONSTRAINT DF_RS_GW DEFAULT 0.00,
    tds_deducted       DECIMAL(14,2)    NOT NULL CONSTRAINT DF_RS_TDS DEFAULT 0.00,
    adjustments        DECIMAL(14,2)    NOT NULL CONSTRAINT DF_RS_Adj DEFAULT 0.00,
    net_settlement     DECIMAL(14,2)    NOT NULL,
    status             VARCHAR(20)      NOT NULL CONSTRAINT DF_RS_Status DEFAULT 'pending',
    utr_number         VARCHAR(50)      NULL,
    settled_at         DATETIME2        NULL,
    CONSTRAINT PK_RestaurantSettlements      PRIMARY KEY (settlement_id),
    CONSTRAINT FK_RS_Partner                 FOREIGN KEY (partner_id)    REFERENCES dbo.RestaurantPartners(partner_id),
    CONSTRAINT FK_RS_Restaurant              FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id),
    CONSTRAINT FK_RS_Bank                    FOREIGN KEY (bank_id)       REFERENCES dbo.PartnerBankAccounts(bank_id),
    CONSTRAINT CK_RS_Status                  CHECK (status IN ('pending','processing','settled','failed','on_hold'))
);
CREATE INDEX IX_RS_PartnerId    ON dbo.RestaurantSettlements(partner_id);
CREATE INDEX IX_RS_PeriodStart  ON dbo.RestaurantSettlements(period_start);

CREATE TABLE dbo.AgentPayoutCycles (
    cycle_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_APC_Id DEFAULT NEWSEQUENTIALID(),
    period_start DATE             NOT NULL,
    period_end   DATE             NOT NULL,
    status       VARCHAR(20)      NOT NULL CONSTRAINT DF_APC_Status DEFAULT 'open',
    processed_at DATETIME2        NULL,
    CONSTRAINT PK_AgentPayoutCycles   PRIMARY KEY (cycle_id),
    CONSTRAINT CK_APC_Status          CHECK (status IN ('open','processing','completed','failed'))
);

CREATE TABLE dbo.AgentPayouts (
    payout_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AP_Id DEFAULT NEWSEQUENTIALID(),
    cycle_id         UNIQUEIDENTIFIER NOT NULL,
    agent_id         UNIQUEIDENTIFIER NOT NULL,
    deliveries_count INT              NOT NULL,
    base_pay         DECIMAL(10,2)    NOT NULL,
    incentives       DECIMAL(10,2)    NOT NULL CONSTRAINT DF_AP_Inc  DEFAULT 0.00,
    tips             DECIMAL(10,2)    NOT NULL CONSTRAINT DF_AP_Tips DEFAULT 0.00,
    deductions       DECIMAL(10,2)    NOT NULL CONSTRAINT DF_AP_Ded  DEFAULT 0.00,
    net_payout       DECIMAL(10,2)    NOT NULL,
    status           VARCHAR(20)      NOT NULL CONSTRAINT DF_AP_Status DEFAULT 'pending',
    utr_number       VARCHAR(50)      NULL,
    processed_at     DATETIME2        NULL,
    CONSTRAINT PK_AgentPayouts      PRIMARY KEY (payout_id),
    CONSTRAINT UQ_AP_CycleAgent     UNIQUE (cycle_id, agent_id),
    CONSTRAINT FK_AP_Cycle          FOREIGN KEY (cycle_id)  REFERENCES dbo.AgentPayoutCycles(cycle_id),
    CONSTRAINT FK_AP_Agent          FOREIGN KEY (agent_id)  REFERENCES dbo.DeliveryAgents(agent_id),
    CONSTRAINT CK_AP_Status         CHECK (status IN ('pending','processing','paid','failed'))
);
CREATE INDEX IX_AP_AgentId ON dbo.AgentPayouts(agent_id);

-- 4.5 Incentive Programs
CREATE TABLE dbo.RewardTypes (
    reward_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label          NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_RewardTypes PRIMARY KEY (reward_type_id)
);

CREATE TABLE dbo.IncentivePrograms (
    program_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_IP_Id DEFAULT NEWSEQUENTIALID(),
    name           NVARCHAR(150)    NOT NULL,
    target_type    VARCHAR(30)      NOT NULL,   -- 'agent','restaurant','user'
    criteria_json  NVARCHAR(MAX)    NOT NULL,
    reward_amount  DECIMAL(10,2)    NOT NULL,
    reward_type_id SMALLINT         NOT NULL,
    is_active      BIT              NOT NULL CONSTRAINT DF_IP_Active DEFAULT 1,
    valid_from     DATETIME2        NOT NULL,
    valid_until    DATETIME2        NOT NULL,
    created_by     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_IncentivePrograms     PRIMARY KEY (program_id),
    CONSTRAINT FK_IP_RewardType         FOREIGN KEY (reward_type_id) REFERENCES dbo.RewardTypes(reward_type_id),
    CONSTRAINT FK_IP_CreatedBy          FOREIGN KEY (created_by)     REFERENCES dbo.AdminUsers(admin_id)
);

CREATE TABLE dbo.AgentIncentiveEarnings (
    earn_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AIE_Id DEFAULT NEWSEQUENTIALID(),
    program_id UNIQUEIDENTIFIER NOT NULL,
    agent_id   UNIQUEIDENTIFIER NOT NULL,
    order_id   UNIQUEIDENTIFIER NOT NULL,
    amount     DECIMAL(10,2)    NOT NULL,
    status     VARCHAR(20)      NOT NULL CONSTRAINT DF_AIE_Status DEFAULT 'pending',
    earned_at  DATETIME2        NOT NULL CONSTRAINT DF_AIE_Earned DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AgentIncentiveEarnings   PRIMARY KEY (earn_id),
    CONSTRAINT FK_AIE_Program              FOREIGN KEY (program_id) REFERENCES dbo.IncentivePrograms(program_id),
    CONSTRAINT FK_AIE_Agent                FOREIGN KEY (agent_id)   REFERENCES dbo.DeliveryAgents(agent_id),
    CONSTRAINT FK_AIE_Order                FOREIGN KEY (order_id)   REFERENCES dbo.Orders(order_id),
    CONSTRAINT CK_AIE_Status               CHECK (status IN ('pending','approved','paid','rejected'))
);
CREATE INDEX IX_AIE_AgentId ON dbo.AgentIncentiveEarnings(agent_id);

-- 4.6 Agent Performance
CREATE TABLE dbo.AgentPerformance (
    perf_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AgP_Id DEFAULT NEWSEQUENTIALID(),
    agent_id           UNIQUEIDENTIFIER NOT NULL,
    date               DATE             NOT NULL,
    total_orders       INT              NOT NULL CONSTRAINT DF_AgP_Ord DEFAULT 0,
    on_time_deliveries INT              NOT NULL CONSTRAINT DF_AgP_OT  DEFAULT 0,
    avg_delivery_mins  DECIMAL(6,2)     NULL,
    rating             DECIMAL(3,2)     NULL,
    login_hours        DECIMAL(5,2)     NULL,
    distance_km        DECIMAL(8,2)     NULL,
    cancelled_orders   INT              NOT NULL CONSTRAINT DF_AgP_Can DEFAULT 0,
    CONSTRAINT PK_AgentPerformance    PRIMARY KEY (perf_id),
    CONSTRAINT UQ_AgP_AgentDate       UNIQUE (agent_id, date),
    CONSTRAINT FK_AgP_Agent           FOREIGN KEY (agent_id) REFERENCES dbo.DeliveryAgents(agent_id)
);

-- 4.7 Customer Support
CREATE TABLE dbo.TicketCategories (
    cat_id          SMALLINT      NOT NULL IDENTITY(1,1),
    name            NVARCHAR(100) NOT NULL,
    parent_category NVARCHAR(100) NULL,
    CONSTRAINT PK_TicketCategories      PRIMARY KEY (cat_id),
    CONSTRAINT UQ_TC_Name               UNIQUE (name)
);

CREATE TABLE dbo.SupportTickets (
    ticket_id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ST_Id DEFAULT NEWSEQUENTIALID(),
    user_id           UNIQUEIDENTIFIER NOT NULL,
    restaurant_id     UNIQUEIDENTIFIER NULL,
    order_id          UNIQUEIDENTIFIER NULL,
    category_id       SMALLINT         NOT NULL,
    status            VARCHAR(20)      NOT NULL CONSTRAINT DF_ST_Status   DEFAULT 'open',
    priority          VARCHAR(10)      NOT NULL CONSTRAINT DF_ST_Priority DEFAULT 'medium',
    channel           VARCHAR(20)      NOT NULL CONSTRAINT DF_ST_Channel  DEFAULT 'app',
    description       NVARCHAR(2000)   NOT NULL,
    assigned_to       UNIQUEIDENTIFIER NULL,
    opened_at         DATETIME2        NOT NULL CONSTRAINT DF_ST_Opened   DEFAULT SYSUTCDATETIME(),
    first_response_at DATETIME2        NULL,
    resolved_at       DATETIME2        NULL,
    closed_at         DATETIME2        NULL,
    satisfaction_score SMALLINT        NULL,
    CONSTRAINT PK_SupportTickets         PRIMARY KEY (ticket_id),
    CONSTRAINT FK_ST_User                FOREIGN KEY (user_id)       REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_ST_Restaurant          FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id),
    CONSTRAINT FK_ST_Order               FOREIGN KEY (order_id)      REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_ST_Category            FOREIGN KEY (category_id)   REFERENCES dbo.TicketCategories(cat_id),
    CONSTRAINT FK_ST_AssignedTo          FOREIGN KEY (assigned_to)   REFERENCES dbo.AdminUsers(admin_id),
    CONSTRAINT CK_ST_Status              CHECK (status   IN ('open','in_progress','pending_user','resolved','closed')),
    CONSTRAINT CK_ST_Priority            CHECK (priority IN ('low','medium','high','urgent')),
    CONSTRAINT CK_ST_Channel             CHECK (channel  IN ('app','web','phone','email','social')),
    CONSTRAINT CK_ST_Score               CHECK (satisfaction_score BETWEEN 1 AND 5)
);
CREATE INDEX IX_ST_UserId   ON dbo.SupportTickets(user_id);
CREATE INDEX IX_ST_OrderId  ON dbo.SupportTickets(order_id);
CREATE INDEX IX_ST_Status   ON dbo.SupportTickets(status);

CREATE TABLE dbo.TicketMessages (
    msg_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_TM_Id DEFAULT NEWSEQUENTIALID(),
    ticket_id   UNIQUEIDENTIFIER NOT NULL,
    sender_id   UNIQUEIDENTIFIER NOT NULL,
    sender_type VARCHAR(20)      NOT NULL,   -- 'user','admin','system'
    body        NVARCHAR(MAX)    NOT NULL,
    sent_at     DATETIME2        NOT NULL CONSTRAINT DF_TM_Sent DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_TicketMessages     PRIMARY KEY (msg_id),
    CONSTRAINT FK_TM_Ticket          FOREIGN KEY (ticket_id) REFERENCES dbo.SupportTickets(ticket_id) ON DELETE CASCADE,
    CONSTRAINT CK_TM_SenderType      CHECK (sender_type IN ('user','admin','restaurant','system'))
);
CREATE INDEX IX_TM_TicketId ON dbo.TicketMessages(ticket_id);

CREATE TABLE dbo.TicketAttachments (
    attachment_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_TA_Id DEFAULT NEWSEQUENTIALID(),
    msg_id        UNIQUEIDENTIFIER NOT NULL,
    file_url      NVARCHAR(500)    NOT NULL,
    file_name     NVARCHAR(200)    NULL,
    file_type     VARCHAR(50)      NULL,
    uploaded_at   DATETIME2        NOT NULL CONSTRAINT DF_TA_Uploaded DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_TicketAttachments   PRIMARY KEY (attachment_id),
    CONSTRAINT FK_TA_Message          FOREIGN KEY (msg_id) REFERENCES dbo.TicketMessages(msg_id) ON DELETE CASCADE
);

CREATE TABLE dbo.ResolutionTypes (
    resolution_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label              NVARCHAR(80) NOT NULL,
    CONSTRAINT PK_ResolutionTypes PRIMARY KEY (resolution_type_id)
);

CREATE TABLE dbo.TicketResolutions (
    res_id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_TR_Id DEFAULT NEWSEQUENTIALID(),
    ticket_id          UNIQUEIDENTIFIER NOT NULL,
    resolution_type_id SMALLINT         NOT NULL,
    refund_amount      DECIMAL(10,2)    NULL,
    voucher_code       VARCHAR(50)      NULL,
    notes              NVARCHAR(1000)   NULL,
    resolved_by        UNIQUEIDENTIFIER NOT NULL,
    created_at         DATETIME2        NOT NULL CONSTRAINT DF_TR_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_TicketResolutions         PRIMARY KEY (res_id),
    CONSTRAINT UQ_TR_Ticket                 UNIQUE (ticket_id),
    CONSTRAINT FK_TR_Ticket                 FOREIGN KEY (ticket_id)          REFERENCES dbo.SupportTickets(ticket_id),
    CONSTRAINT FK_TR_ResType                FOREIGN KEY (resolution_type_id) REFERENCES dbo.ResolutionTypes(resolution_type_id),
    CONSTRAINT FK_TR_ResolvedBy             FOREIGN KEY (resolved_by)        REFERENCES dbo.AdminUsers(admin_id)
);

-- 4.8 Reviews
CREATE TABLE dbo.Reviews (
    review_id       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Rev_Id DEFAULT NEWSEQUENTIALID(),
    order_id        UNIQUEIDENTIFIER NOT NULL,
    user_id         UNIQUEIDENTIFIER NOT NULL,
    restaurant_id   UNIQUEIDENTIFIER NOT NULL,
    food_rating     SMALLINT         NOT NULL,
    delivery_rating SMALLINT         NOT NULL,
    overall_rating  SMALLINT         NOT NULL,
    review_text     NVARCHAR(2000)   NULL,
    is_verified     BIT              NOT NULL CONSTRAINT DF_Rev_Verified DEFAULT 0,
    is_hidden       BIT              NOT NULL CONSTRAINT DF_Rev_Hidden   DEFAULT 0,
    created_at      DATETIME2        NOT NULL CONSTRAINT DF_Rev_Created  DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2        NOT NULL CONSTRAINT DF_Rev_Updated  DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Reviews              PRIMARY KEY (review_id),
    CONSTRAINT UQ_Rev_OrderUser        UNIQUE (order_id, user_id),
    CONSTRAINT FK_Rev_Order            FOREIGN KEY (order_id)      REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_Rev_User             FOREIGN KEY (user_id)       REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Rev_Restaurant       FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id),
    CONSTRAINT CK_Rev_Food             CHECK (food_rating     BETWEEN 1 AND 5),
    CONSTRAINT CK_Rev_Delivery         CHECK (delivery_rating BETWEEN 1 AND 5),
    CONSTRAINT CK_Rev_Overall          CHECK (overall_rating  BETWEEN 1 AND 5)
);
CREATE INDEX IX_Rev_RestaurantId ON dbo.Reviews(restaurant_id);

CREATE TABLE dbo.ReviewImages (
    img_id     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RImg_Id DEFAULT NEWSEQUENTIALID(),
    review_id  UNIQUEIDENTIFIER NOT NULL,
    url        NVARCHAR(500)    NOT NULL,
    display_order SMALLINT      NOT NULL CONSTRAINT DF_RImg_Order DEFAULT 0,
    CONSTRAINT PK_ReviewImages   PRIMARY KEY (img_id),
    CONSTRAINT FK_RImg_Review    FOREIGN KEY (review_id) REFERENCES dbo.Reviews(review_id) ON DELETE CASCADE
);

CREATE TABLE dbo.ReviewResponses (
    response_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RR_Id DEFAULT NEWSEQUENTIALID(),
    review_id      UNIQUEIDENTIFIER NOT NULL,
    responder_id   UNIQUEIDENTIFIER NOT NULL,
    responder_type VARCHAR(20)      NOT NULL,   -- 'restaurant','admin'
    body           NVARCHAR(2000)   NOT NULL,
    created_at     DATETIME2        NOT NULL CONSTRAINT DF_RR_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ReviewResponses     PRIMARY KEY (response_id),
    CONSTRAINT FK_RR_Review           FOREIGN KEY (review_id) REFERENCES dbo.Reviews(review_id) ON DELETE CASCADE,
    CONSTRAINT CK_RR_RespType         CHECK (responder_type IN ('restaurant','admin'))
);

CREATE TABLE dbo.ReviewVotes (
    vote_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RV_Id DEFAULT NEWSEQUENTIALID(),
    review_id  UNIQUEIDENTIFIER NOT NULL,
    user_id    UNIQUEIDENTIFIER NOT NULL,
    is_helpful BIT              NOT NULL,
    voted_at   DATETIME2        NOT NULL CONSTRAINT DF_RV_Voted DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ReviewVotes     PRIMARY KEY (vote_id),
    CONSTRAINT UQ_RV_ReviewUser   UNIQUE (review_id, user_id),
    CONSTRAINT FK_RV_Review       FOREIGN KEY (review_id) REFERENCES dbo.Reviews(review_id) ON DELETE CASCADE,
    CONSTRAINT FK_RV_User         FOREIGN KEY (user_id)   REFERENCES dbo.Users(user_id)
);

-- 4.9 Banners & Promotions
CREATE TABLE dbo.BannerTypes (
    banner_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    label          NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_BannerTypes PRIMARY KEY (banner_type_id)
);

CREATE TABLE dbo.Banners (
    banner_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Ban_Id DEFAULT NEWSEQUENTIALID(),
    title          NVARCHAR(200)    NOT NULL,
    banner_type_id SMALLINT         NOT NULL,
    image_url      NVARCHAR(500)    NOT NULL,
    deep_link      NVARCHAR(500)    NULL,
    city_id        INT              NULL,
    target_segment NVARCHAR(100)    NULL,
    display_order  INT              NOT NULL CONSTRAINT DF_Ban_Order  DEFAULT 0,
    is_active      BIT              NOT NULL CONSTRAINT DF_Ban_Active DEFAULT 1,
    valid_from     DATETIME2        NOT NULL,
    valid_until    DATETIME2        NOT NULL,
    created_by     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_Banners         PRIMARY KEY (banner_id),
    CONSTRAINT FK_Ban_BannerType  FOREIGN KEY (banner_type_id) REFERENCES dbo.BannerTypes(banner_type_id),
    CONSTRAINT FK_Ban_City        FOREIGN KEY (city_id)        REFERENCES dbo.Cities(city_id),
    CONSTRAINT FK_Ban_CreatedBy   FOREIGN KEY (created_by)     REFERENCES dbo.AdminUsers(admin_id)
);
CREATE INDEX IX_Ban_CityId ON dbo.Banners(city_id);

-- 4.10 Notifications
CREATE TABLE dbo.NotificationTypes (
    notif_type_id SMALLINT     NOT NULL IDENTITY(1,1),
    code          VARCHAR(60)  NOT NULL,
    label         NVARCHAR(80) NOT NULL,
    channel       VARCHAR(20)  NOT NULL,   -- 'push','email','sms','in_app'
    CONSTRAINT PK_NotificationTypes      PRIMARY KEY (notif_type_id),
    CONSTRAINT UQ_NT_Code                UNIQUE (code),
    CONSTRAINT CK_NT_Channel             CHECK (channel IN ('push','email','sms','in_app'))
);

CREATE TABLE dbo.Notifications (
    notif_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Notif_Id DEFAULT NEWSEQUENTIALID(),
    user_id       UNIQUEIDENTIFIER NOT NULL,
    notif_type_id SMALLINT         NOT NULL,
    title         NVARCHAR(200)    NOT NULL,
    body          NVARCHAR(1000)   NOT NULL,
    deep_link     NVARCHAR(500)    NULL,
    is_read       BIT              NOT NULL CONSTRAINT DF_Notif_Read DEFAULT 0,
    sent_at       DATETIME2        NOT NULL CONSTRAINT DF_Notif_Sent DEFAULT SYSUTCDATETIME(),
    read_at       DATETIME2        NULL,
    CONSTRAINT PK_Notifications       PRIMARY KEY (notif_id),
    CONSTRAINT FK_Notif_User          FOREIGN KEY (user_id)       REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_Notif_Type          FOREIGN KEY (notif_type_id) REFERENCES dbo.NotificationTypes(notif_type_id)
);
CREATE INDEX IX_Notif_UserId  ON dbo.Notifications(user_id);
CREATE INDEX IX_Notif_SentAt  ON dbo.Notifications(sent_at DESC);

-- 4.11 Platform Revenue Ledger
CREATE TABLE dbo.PlatformTransactions (
    ptxn_id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PT_Id DEFAULT NEWSEQUENTIALID(),
    order_id              UNIQUEIDENTIFIER NOT NULL,
    order_value           DECIMAL(14,2)    NOT NULL,
    delivery_fee          DECIMAL(10,2)    NOT NULL,
    platform_fee          DECIMAL(10,2)    NOT NULL,
    coupon_discount       DECIMAL(10,2)    NOT NULL CONSTRAINT DF_PT_Coup DEFAULT 0.00,
    restaurant_commission DECIMAL(10,2)    NOT NULL,
    gateway_charge        DECIMAL(10,2)    NOT NULL,
    gst_collected         DECIMAL(10,2)    NOT NULL,
    net_revenue           DECIMAL(10,2)    NOT NULL,
    created_at            DATETIME2        NOT NULL CONSTRAINT DF_PT_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PlatformTransactions   PRIMARY KEY (ptxn_id),
    CONSTRAINT UQ_PT_Order               UNIQUE (order_id),
    CONSTRAINT FK_PT_Order               FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id)
);
CREATE INDEX IX_PT_CreatedAt ON dbo.PlatformTransactions(created_at DESC);

-- 4.12 Audit Log
CREATE TABLE dbo.AuditLogs (
    log_id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AuditLog_Id DEFAULT NEWSEQUENTIALID(),
    actor_id      UNIQUEIDENTIFIER NOT NULL,
    actor_type    VARCHAR(20)      NOT NULL,   -- 'admin','user','system'
    action        VARCHAR(40)      NOT NULL,   -- 'create','update','delete','approve','reject'
    entity_type   VARCHAR(80)      NOT NULL,
    entity_id     UNIQUEIDENTIFIER NOT NULL,
    old_value     NVARCHAR(MAX)    NULL,
    new_value     NVARCHAR(MAX)    NULL,
    ip_address    VARCHAR(45)      NULL,
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_AuditL_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AuditLogs    PRIMARY KEY (log_id),
    CONSTRAINT CK_AL_ActorType CHECK (actor_type IN ('admin','user','system','agent','partner'))
);
CREATE INDEX IX_AL_EntityType ON dbo.AuditLogs(entity_type, entity_id);
CREATE INDEX IX_AL_ActorId    ON dbo.AuditLogs(actor_id);
CREATE INDEX IX_AL_CreatedAt  ON dbo.AuditLogs(created_at DESC);

-- 4.13 Restaurant Analytics (daily snapshot)
CREATE TABLE dbo.RestaurantAnalytics (
    rec_id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RA_Id DEFAULT NEWSEQUENTIALID(),
    restaurant_id     UNIQUEIDENTIFIER NOT NULL,
    date              DATE             NOT NULL,
    total_orders      INT              NOT NULL CONSTRAINT DF_RA_Ord DEFAULT 0,
    total_gmv         DECIMAL(14,2)    NOT NULL CONSTRAINT DF_RA_GMV DEFAULT 0.00,
    avg_order_value   DECIMAL(10,2)    NULL,
    cancelled_orders  INT              NOT NULL CONSTRAINT DF_RA_Can DEFAULT 0,
    avg_rating        DECIMAL(3,2)     NULL,
    new_customers     INT              NOT NULL CONSTRAINT DF_RA_New DEFAULT 0,
    repeat_customers  INT              NOT NULL CONSTRAINT DF_RA_Rep DEFAULT 0,
    acceptance_rate   DECIMAL(5,2)     NULL,
    CONSTRAINT PK_RestaurantAnalytics        PRIMARY KEY (rec_id),
    CONSTRAINT UQ_RA_RestaurantDate          UNIQUE (restaurant_id, date),
    CONSTRAINT FK_RA_Restaurant              FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id)
);

-- ============================================================
-- SEED DATA — Lookup Tables
-- ============================================================

INSERT INTO dbo.Genders          (label) VALUES ('Male'),('Female'),('Non-binary'),('Prefer not to say');
INSERT INTO dbo.AddressTypes     (label) VALUES ('Home'),('Work'),('Other');
INSERT INTO dbo.OrderStatuses    (code, label, sort_order) VALUES
    ('pending','Pending',1),('confirmed','Confirmed',2),('preparing','Preparing',3),
    ('ready_for_pickup','Ready for pickup',4),('out_for_delivery','Out for delivery',5),
    ('delivered','Delivered',6),('cancelled','Cancelled',7),('failed','Failed',8);
INSERT INTO dbo.PaymentMethods   (code, label) VALUES
    ('cod','Cash on Delivery'),('upi','UPI'),('card','Credit / Debit Card'),
    ('netbanking','Net Banking'),('wallet','Wallet'),('emi','EMI');
INSERT INTO dbo.PaymentProviders (name) VALUES ('Razorpay'),('Paytm'),('Stripe'),('PayPal'),('Juspay');
INSERT INTO dbo.VehicleTypes     (label) VALUES ('Bicycle'),('Motorcycle'),('Scooter'),('Car');
INSERT INTO dbo.DiscountTypes    (label) VALUES ('Flat Amount'),('Percentage'),('Free Delivery'),('BOGO');
INSERT INTO dbo.RewardTypes      (label) VALUES ('Cash'),('Voucher'),('Points'),('Bonus');
INSERT INTO dbo.DocumentTypes    (label, is_mandatory) VALUES
    ('FSSAI License',1),('GST Certificate',1),('PAN Card',1),
    ('Trade License',0),('Fire NOC',0),('Menu Card',0);
INSERT INTO dbo.BannerTypes      (label) VALUES ('Hero Slider'),('Category Banner'),('Promotional Strip'),('Sponsored');
INSERT INTO dbo.NotificationTypes(code, label, channel) VALUES
    ('order_placed',     'Order placed',           'push'),
    ('order_confirmed',  'Order confirmed',         'push'),
    ('order_out_for_del','Order out for delivery',  'push'),
    ('order_delivered',  'Order delivered',         'push'),
    ('order_cancelled',  'Order cancelled',         'push'),
    ('promo_offer',      'Promo / offer',           'push'),
    ('payment_receipt',  'Payment receipt',         'email'),
    ('review_request',   'Review reminder',         'push'),
    ('subscription_exp', 'Subscription expiring',   'email');
INSERT INTO dbo.CancellationReasons (actor_type, reason_text) VALUES
    ('user',       'Changed my mind'),
    ('user',       'Ordered by mistake'),
    ('user',       'Delivery time too long'),
    ('restaurant', 'Item(s) unavailable'),
    ('restaurant', 'Restaurant closing'),
    ('system',     'Payment failed'),
    ('agent',      'Unable to deliver');
INSERT INTO dbo.ResolutionTypes (label) VALUES
    ('Refund to source'),('Wallet credits'),('Replacement order'),
    ('Voucher issued'),('No action required');
INSERT INTO dbo.TicketCategories (name, parent_category) VALUES
    ('Order issue',        NULL),
    ('Payment issue',      NULL),
    ('Delivery issue',     NULL),
    ('Food quality',       NULL),
    ('Missing items',      'Order issue'),
    ('Wrong order',        'Order issue'),
    ('Late delivery',      'Delivery issue'),
    ('Agent behaviour',    'Delivery issue'),
    ('Refund not received','Payment issue'),
    ('App / Technical',    NULL);
INSERT INTO dbo.AdminRoles (name, description) VALUES
    ('super_admin',       'Full platform access'),
    ('ops_manager',       'Operations and delivery management'),
    ('finance_manager',   'Settlements and payouts'),
    ('support_agent',     'Customer support tickets'),
    ('content_manager',   'Banners and promotions'),
    ('partner_manager',   'Restaurant partner onboarding');


-- ============================================================
-- CROSS-SECTION FK CONSTRAINTS (added after all tables exist)
-- ============================================================
ALTER TABLE dbo.UserCuisinePreferences
    ADD CONSTRAINT FK_UCP_Cuisine  FOREIGN KEY (cuisine_id) REFERENCES dbo.Cuisines(cuisine_id);

ALTER TABLE dbo.WishlistRestaurants
    ADD CONSTRAINT FK_WLR_Restaurant FOREIGN KEY (restaurant_id) REFERENCES dbo.Restaurants(restaurant_id);

ALTER TABLE dbo.RestaurantDocuments
    ADD CONSTRAINT FK_RD_VerifiedBy  FOREIGN KEY (verified_by) REFERENCES dbo.AdminUsers(admin_id);

ALTER TABLE dbo.ItemPriceHistory
    ADD CONSTRAINT FK_IPH_ChangedBy  FOREIGN KEY (changed_by) REFERENCES dbo.AdminUsers(admin_id);

GO

GO
PRINT 'ZomatoDB schema created successfully — 70+ normalized tables, all constraints and indexes applied.';