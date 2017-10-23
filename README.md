## Synopsis

Code for downloading and writing keholliset tuntemukset data and writing it to .mat and .csv files. See instructions below.

## Process

How to download and process the raw data from Pain clinic project
1. Navigate to bml.becs.aalto.fi/keholliset_tuntemukset/admin/ and make & download .tar file
2. Run get_data_from_tar.sh on command line in the location where you downloaded your .tar file
get_data_from_tar.sh /path/to/output/folder
3. Run s1_screening_kipu.m, make sure you change path names and include code & bodyspm in your matlab path
4. Run s2_preprocessing_kipu.m, make sure you change path names and include code & bodyspm in your matlab path
(5. Optional: test data visualisation with s3_check_subject_response.m)
6. Run load_bg_data.R, make sure you change path names

## Notes on data organisation
The colouring data are either one-sided (emotions, where subjects colour in activations and deactivations) or two-sided (pain and sensitivity data) where subject colours in front and back of the body. The data are stored in one large matrix (dim: 522x342x12) per subject. Here, emotions are stored in the left half of each matrix (:, 1:171), and two-sided data are stored in whole matrix such that front of the body is on the left size (:, 1:171) and back of the body is in the right side (:, 172:342). Do also note, that one and two sided bodies are slightly different in scaling. Because of this, you'll want to make sure you use the correct outline and mask for that response type (see s3_check_subject_response.m for example).

The order of the stimuli were randomised within each block (see below), but the blocks were always presented in the order below. If you want to see exact order of stimuli presented to a particular subject, see presentation_[block name].txt in that subject's folder.

##Order of stimuli in the matrix:

###emotion block
'Arvioi alla oleviin kuviin, miten kehosi toiminta muuttuu, kun koet'
1. surua
2. iloa
3. vihaa
4. hämmästyneisyyttä
5. pelkoa
6. inhoa
7. ei mitään erityistä (neutraali)

###pain block
8. Väritä kuviin ne alueet, joissa koet kipua juuri tällä hetkellä
9. Väritä kuviin ne alueet, joissa koet usein toistuvaa ja/tai pitkäkestoista kipua

###sensitivity block
10. Väritä kuviin ne alueet, joissa tunnet pienenkin kosketuksen herkästi
11. Väritä kuviin ne alueet, jotka ovat erityisen kipuherkkiä
12. Väritä kuviin ne alueet, joihin kohdistuva kosketus tuntuu Sinusta mukavalta

## Problems?
Contact juulia dot suvilehto at aalto dot fi . 
