from multiprocessing import Pool
import sys

from imagehash import average_hash as ahash, phash, dhash, whash
import numpy as np
from os.path import basename
from PIL import Image
from sklearn.cluster import KMeans
from tqdm import tqdm


def vectorize_image(filename):
    image = Image.open(filename).convert('RGBA')
    return np.concatenate((
        ahash(image).hash.flatten(),
        phash(image).hash.flatten(),
        dhash(image).hash.flatten(),
        whash(image).hash.flatten(),
    ))


if __name__ == '__main__':
    input_images_filename = sys.argv[1]
    pickled_input_images_filename = '{}.npy'.format(input_images_filename)
    output_representatives_filename = sys.argv[2]
    output_renames_filename = sys.argv[3]
    output_symlinks_filename = sys.argv[4]
    number_of_clusters = int(sys.argv[5])

    print('Reading image filenames from {}'.format(input_images_filename))
    filenames = []
    with open(input_images_filename, 'rt') as f:
        for filename in f:
            filename = filename.rstrip('\n')
            filenames.append(filename)

    try:
        images = np.load(pickled_input_images_filename)
        print('Reading hashed images from {}'.format(pickled_input_images_filename))
    except IOError:
        images = []
        with Pool(None) as pool:
            for image in pool.imap(
                        vectorize_image,
                        tqdm(
                            filenames,
                            desc='Hashing images'.format(input_images_filename),
                        ),
                    ):
                images.append(image)
        images = np.array(images)
        np.save(pickled_input_images_filename, images)

    print('Finding {} clusters'.format(number_of_clusters))
    k_means = KMeans(n_clusters=number_of_clusters)
    k_means.fit(images)

    representatives = {}
    symlinks = {}
    for filename, label in zip(filenames, k_means.labels_):
        if label not in representatives:
            renumbered_filename = '{:06d}.png'.format(len(representatives) + 1)
            representatives[label] = (filename, renumbered_filename)
        else:
            symlinks[filename] = representatives[label][0]

    print('Writing a list of cluster representatives to {}'.format(output_representatives_filename))
    with open(output_representatives_filename, 'wt') as f:
        for filename, _ in sorted(representatives.values()):
            print(filename, file=f)

    print('Writing a list of renames to {}'.format(output_renames_filename))
    with open(output_renames_filename, 'wt') as f:
        for filename, renumbered_filename in sorted(representatives.values(), reverse=True):
            if basename(renumbered_filename) != basename(filename):
                print('{}\t{}'.format(
                    basename(renumbered_filename),
                    basename(filename),
                ), file=f)

    print('Writing a list of symlinks to {}'.format(output_symlinks_filename))
    with open(output_symlinks_filename, 'wt') as f:
        for target_filename, source_filename in symlinks.items():
            print('{}\t{}'.format(
                basename(source_filename),
                basename(target_filename)
            ), file=f)
