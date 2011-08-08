SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `hfc1test` ;
USE `hfc1test`;

-- -----------------------------------------------------
-- Table `hfc1test`.`FRC_Info`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`FRC_Info` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT ,
  `INSTITUT` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL COMMENT 'Institute responsible for running the FR code' ,
  `CODE` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL COMMENT 'Name of the FR code' ,
  `VERSION` VARCHAR(50) CHARACTER SET 'latin1' NOT NULL COMMENT 'Version of the FR code' ,
  `FEATURE_NAME` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL COMMENT 'Features detected' ,
  `CONTACT` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL COMMENT 'Person responsible for running the FR code' ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `hfc1test`.`OBSERVATORY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`OBSERVATORY` (
  `Id` INT(11) NOT NULL AUTO_INCREMENT ,
  `Observat` VARCHAR(255) CHARACTER SET 'latin1' NOT NULL ,
  `Instrume` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL ,
  `Telescop` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL ,
  `Units` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL ,
  `Wavelnth` FLOAT NULL DEFAULT NULL ,
  `Wavename` VARCHAR(50) CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  `Waveunit` VARCHAR(10) NULL DEFAULT NULL ,
  `Obs_type` VARCHAR(100) CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  `Comment` TEXT CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `hfc1test`.`OBSERVATIONS`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`OBSERVATIONS` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT ,
  `Observatory_id` INT(11) NOT NULL ,
  `DATE_OBS` DATETIME NOT NULL ,
  `DATE_END` DATETIME NOT NULL ,
  `JDINT` INT(11) NOT NULL COMMENT 'Julian day of the observation, integer part' ,
  `JDFRAC` DOUBLE NOT NULL COMMENT 'Julian day of the observation, fraction part' ,
  `EXP_TIME` FLOAT NULL DEFAULT NULL COMMENT 'Exposure time (if available), in seconds and fraction of s' ,
  `C_ROTATION` INT(7) NOT NULL COMMENT 'Carrington rotation' ,
  `BSCALE` DOUBLE NULL DEFAULT NULL COMMENT 'as extracted from the header' ,
  `BZERO` DOUBLE NULL DEFAULT NULL COMMENT 'As extracted from the header' ,
  `BITPIX` INT(3) NOT NULL COMMENT 'Coding of the original image' ,
  `NAXIS1` INT(6) NOT NULL COMMENT 'First dimension of the original image (X)' ,
  `NAXIS2` INT(6) NOT NULL COMMENT 'Second dimension of the original image (Y)' ,
  `R_SUN` DOUBLE NOT NULL COMMENT 'Radius of the Sun in pixels' ,
  `CENTER_X` DOUBLE NOT NULL COMMENT 'X coordinate of Sun centre in pixels' ,
  `CENTER_Y` DOUBLE NOT NULL COMMENT 'Y coordinate of Sun centre in pixels' ,
  `CDELT1` DOUBLE NOT NULL COMMENT 'Spatial scale of the original observation (X axis) (in arsec)' ,
  `CDELT2` DOUBLE NOT NULL COMMENT 'Spatial scale of the original observation (Y axis) (in arsec)' ,
  `QUALITY` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Quality of the original image (in terms of processing)' ,
  `FILENAME` VARCHAR(100) NOT NULL COMMENT 'Name of the orignal file' ,
  `DATE_OBS_STRING` VARCHAR(150) NOT NULL ,
  `DATE_END_STRING` VARCHAR(150) NOT NULL ,
  `COMMENT` TEXT NOT NULL COMMENT 'As extracted from the header' ,
  `LOC_FILENAME` VARCHAR(200) NOT NULL ,
  `ID2` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY USING BTREE (`ID`) ,
  UNIQUE INDEX `FILENAME` (`FILENAME` ASC) ,
  INDEX `new_fk_constraint` (`Observatory_id` ASC) ,
  CONSTRAINT `new_fk_constraint`
    FOREIGN KEY (`Observatory_id` )
    REFERENCES `hfc1test`.`OBSERVATORY` (`Id` ))
ENGINE = InnoDB
AUTO_INCREMENT = 0
DEFAULT CHARACTER SET = utf8;



-- -----------------------------------------------------
-- Table `hfc1test`.`ACTIVEREGIONS`  (SMART)
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`ACTIVEREGIONS` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT ,
  `FRC_INFO_ID` INT(4) NOT NULL COMMENT 'Ref. to FR code information' ,
  `OBSERVATION_ID` INT(11) NOT NULL COMMENT  'Pointing to observation',
  `OBSERVATION_ID_T` INT(11) NOT NULL COMMENT  'Pointing to observation',
  `RUN_DATE` DATETIME NOT NULL COMMENT 'Date when FR code was run' ,
  `AR_DATE` DATETIME NOT NULL COMMENT 'Date when FR code was run' ,
  `AR_DATE_T` DATETIME NOT NULL COMMENT 'Date when FR code was run' ,
  `FEATC_X_ARCSEC` DOUBLE NOT NULL COMMENT 'X coordinate of gravity centre in arcsec' ,
  `ARC_ARC_Y` DOUBLE NOT NULL COMMENT 'Y coordinate of the gravity centre in arsec' ,
  `SC_HG_LON` DOUBLE NOT NULL COMMENT 'Heliographic longitude of AR Gravity centre in degrees' ,
  `SC_HG_LAT` DOUBLE NOT NULL COMMENT 'Heliographic latitude of AR Gravity centre in degrees' ,
  `FEAT_NPIX` INT(11) NOT NULL COMMENT 'Number of pixels included in the feature' ,
  `FEAT_AREA` DOUBLE NOT NULL COMMENT 'Area of the feature in square degrees' ,
  `BR_ARC_X1` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate East most point in arsec' ,
  `BR_ARC_Y1` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate South most point in arsec' ,
  `BR_ARC_X2` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate West most point in arsec' ,
  `BR_ARC_Y2` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate North most point in arsec' ,
  `BR_HG_LON1` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate East most point in HG coordinates in degrees',
  `BR_HG_LAT1` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate South most point in HG coordinates in degrees',
  `BR_HG_LON2` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate West most point in HG coordinates in degrees',
  `BR_HG_LAT2` DOUBLE NOT NULL COMMENT 'Bounding rectangle coordinate North most point in HG coordinates in degrees',
  `BR_PIX_X1` INT(8) NOT NULL COMMENT 'Bounding rectangle coordinate East most point in pixels' ,
  `BR_PIX_Y1` INT(8) NOT NULL COMMENT 'Bounding rectangle coordinate South most point in pixels' ,
  `BR_PIX_X2` INT(8) NOT NULL COMMENT 'Bounding rectangle coordinate West most point in pixels' ,
  `BR_PIX_Y2` INT(8) NOT NULL COMMENT 'Bounding rectangle coordinate North most point in pixels' ,
  `FEAT_MAX_INT` FLOAT NOT NULL COMMENT 'Feature max. value, in Gauss' ,
  `FEAT_MIN_INT` FLOAT NOT NULL COMMENT 'Feature min. value, in Gauss' ,
  `FEAT_MEAN_INT` FLOAT NOT NULL COMMENT 'Feature mean intensity value in Gauss.' ,
  `FEAT_LNL` FLOAT NOT NULL COMMENT 'Feature length of the neutral line in Mm.' ,
  `FEAT_LSG` FLOAT NOT NULL COMMENT 'Feature length of the strong gradient of nl above 50G/Mm.' ,
  `FEAT_GRAD_MAX` FLOAT NOT NULL COMMENT 'Maximum of the horizontal gradient (G/Mm)' ,
  `FEAT_GRAD_MEAN` FLOAT NOT NULL COMMENT 'Mean of the horizontal gradient (G/Mm).' ,
  `FEAT_GRAD_MEDIAN` FLOAT NOT NULL COMMENT 'Median of the horizontal gradient (G/Mm).' ,
  `FEAT_RVAL` FLOAT NOT NULL COMMENT 'R schrijver value (Mx).' ,
  `FEAT_WLSG` FLOAT NOT NULL COMMENT 'WLSG value (G/Mm).' ,
  `ENC_MET` VARCHAR(50) NOT NULL COMMENT 'Encoding method' ,
  `CC_PIX_X` INT(8) NOT NULL COMMENT 'X coordinate of chain code start position in pixels' ,
  `CC_PIX_Y` INT(8) NOT NULL COMMENT 'Y coordinate of chain code start position in pixels' ,
  `CC_ARC_X` FLOAT NOT NULL COMMENT 'X coordinate of chain code start position in arcsec' ,
  `CC_ARC_Y` FLOAT NOT NULL COMMENT 'Y coordinate of chain code start position in arcsec' ,
  `CHAIN_CODE` TEXT NOT NULL COMMENT 'Boundary chain code' ,
  `CCODE_LNTH` INT(11) NOT NULL ,
  `SNAPSHOT_FN` VARCHAR(200) NOT NULL COMMENT 'snapshot of the AR in solarmonitor',
  `SNAPSHOT_PATH` VARCHAR(200) NOT NULL COMMENT 'full URL of the snapshot',
  PRIMARY KEY (`ID`) ,
  INDEX `frc_info_fk_constraint` (`FRC_INFO_ID` ASC) ,
  INDEX `observations_fk_constraint` (`OBSERVATION_ID` ASC) ,
  INDEX `observations_fk_constraint_t` (`OBSERVATION_ID_T` ASC) ,
  CONSTRAINT `frc_info_fk_constraint`
    FOREIGN KEY (`FRC_INFO_ID` )
    REFERENCES `hfc1test`.`FRC_Info` (`ID` ),
  CONSTRAINT `observations_fk_constraint`
    FOREIGN KEY (`OBSERVATION_ID` )
    REFERENCES `hfc1test`.`OBSERVATIONS` (`ID` ),
  CONSTRAINT `observations_fk_constraint_t`
    FOREIGN KEY (`OBSERVATION_ID_T` )
    REFERENCES `hfc1test`.`OBSERVATIONS` (`ID` ))
ENGINE = InnoDB
AUTO_INCREMENT = 0
DEFAULT CHARACTER SET = utf8
ROW_FORMAT = DYNAMIC;




SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



