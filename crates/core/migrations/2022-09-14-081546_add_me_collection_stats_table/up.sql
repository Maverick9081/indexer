BEGIN WORK;
DO $$
BEGIN
  	IF (SELECT NOT EXISTS (SELECT 1 FROM information_schema.tables  WHERE table_schema = 'public' AND table_name = 'me_collection_stats')) THEN
	create table if not exists me_collection_stats (
	  collection_id       uuid 		  primary key,
	  nft_count           bigint      not null,
	  floor_price         bigint      null
	);

	INSERT INTO ME_COLLECTION_STATS (COLLECTION_ID, NFT_COUNT, FLOOR_PRICE) WITH NFT_COUNT_TABLE AS
	(SELECT ME_METADATA_COLLECTIONS.COLLECTION_ID AS COLLECTION_ID,
			COUNT(ME_METADATA_COLLECTIONS.METADATA_ADDRESS) AS NFT_COUNT
		FROM ME_METADATA_COLLECTIONS
		GROUP BY ME_METADATA_COLLECTIONS.COLLECTION_ID),
	FLOOR_PRICE_TABLE AS
	(SELECT ME_METADATA_COLLECTIONS.COLLECTION_ID AS COLLECTION_ID,
			MIN(LISTINGS.PRICE) AS FLOOR_PRICE
		FROM LISTINGS
		INNER JOIN METADATAS ON (LISTINGS.METADATA = METADATAS.ADDRESS)
		INNER JOIN ME_METADATA_COLLECTIONS ON (METADATAS.ADDRESS = ME_METADATA_COLLECTIONS.METADATA_ADDRESS)
		WHERE LISTINGS.MARKETPLACE_PROGRAM = 'M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K'
			AND LISTINGS.PURCHASE_ID IS NULL
			AND LISTINGS.CANCELED_AT IS NULL
		GROUP BY ME_METADATA_COLLECTIONS.COLLECTION_ID)
	SELECT NFT_COUNT_TABLE.COLLECTION_ID,
		NFT_COUNT_TABLE.NFT_COUNT,
		FLOOR_PRICE_TABLE.FLOOR_PRICE
	FROM NFT_COUNT_TABLE,
		FLOOR_PRICE_TABLE
	WHERE NFT_COUNT_TABLE.COLLECTION_ID = FLOOR_PRICE_TABLE.COLLECTION_ID;
    ELSE
    INSERT INTO ME_COLLECTION_STATS (COLLECTION_ID, NFT_COUNT, FLOOR_PRICE) WITH NFT_COUNT_TABLE AS
	(SELECT ME_METADATA_COLLECTIONS.COLLECTION_ID AS COLLECTION_ID,
			COUNT(ME_METADATA_COLLECTIONS.METADATA_ADDRESS) AS NFT_COUNT
		FROM ME_METADATA_COLLECTIONS
		GROUP BY ME_METADATA_COLLECTIONS.COLLECTION_ID),
	FLOOR_PRICE_TABLE AS
	(SELECT ME_METADATA_COLLECTIONS.COLLECTION_ID AS COLLECTION_ID,
			MIN(LISTINGS.PRICE) AS FLOOR_PRICE
		FROM LISTINGS
		INNER JOIN METADATAS ON (LISTINGS.METADATA = METADATAS.ADDRESS)
		INNER JOIN ME_METADATA_COLLECTIONS ON (METADATAS.ADDRESS = ME_METADATA_COLLECTIONS.METADATA_ADDRESS)
		WHERE LISTINGS.MARKETPLACE_PROGRAM = 'M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K'
			AND LISTINGS.PURCHASE_ID IS NULL
			AND LISTINGS.CANCELED_AT IS NULL
		GROUP BY ME_METADATA_COLLECTIONS.COLLECTION_ID)
	SELECT NFT_COUNT_TABLE.COLLECTION_ID,
		NFT_COUNT_TABLE.NFT_COUNT,
		FLOOR_PRICE_TABLE.FLOOR_PRICE
	FROM NFT_COUNT_TABLE,
		FLOOR_PRICE_TABLE
	WHERE NFT_COUNT_TABLE.COLLECTION_ID = FLOOR_PRICE_TABLE.COLLECTION_ID
	ON CONFLICT (COLLECTION_ID) DO UPDATE SET NFT_COUNT = excluded.NFT_COUNT, FLOOR_PRICE = excluded.FLOOR_PRICE;

	END IF;
END $$;
COMMIT WORK;