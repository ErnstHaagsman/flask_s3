from flask import Flask, render_template, request
import boto3

app = Flask(__name__)
s3 = boto3.client('s3')
BUCKET_NAME = ''
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])


@app.route('/', methods=['GET'])
def hello_world():
    return render_template('index.html')


def get_extension(filename: str):
    if '.' not in filename:
        raise ValueError()
    return filename.rsplit('.', 1)[1].lower()


@app.route('/', methods=['POST'])
def upload_file():
    picture = request.files['picture']
    ext = get_extension(picture.filename)
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError()

    new_name = '{}.{}'.format(uuid4(), ext)
    s3.upload_fileobj(picture, BUCKET_NAME, new_name)
    return '<a href="' + new_name +'">Your pic</a>'
