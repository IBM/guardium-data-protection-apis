# Guide on how to explore GuardAPI using python with help of Jupyter Notebooks

## Setup

### Source files

In this folder you have:

- Jyputer notebook with examples of REST API calls to Guardium APIs in python: [Guardium REST API Jupyter Notebook](GuardAPI-REST.ipynb)
- [requirements.txt](requirements.txt) file containing python dependencies you will need to lauch above Jupyter Notebook and extra libraries required to read values of environment variables (with Guardium URL, user credentials, etc) and do REST API calls

### Preparations

1. Create and activate python virtual environment to isolate you dependencies(libraries) you need for this exercise from your global python modules https://docs.python.org/3/library/venv.html. This will let you easy clean up after you're done with experiments and prevent problems with conflicting libraries versions.
2. After you have your python virtual environment created and active, import dependencies required to run Jupyter Notebook

```bash
pip install -r requirements.txt
```

3. Start Jupyter and open 

```bash
jupyter notebook
```

4. Follow instructions in Jupyter Notebook
