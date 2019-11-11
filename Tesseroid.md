# POST request example
```sh
curl -X POST https://mcbn0jkd8l.execute-api.eu-central-1.amazonaws.com/dev/ocr -d "https://i.imgur.com/zGRdhAT.jpg"
curl -X POST https://mcbn0jkd8l.execute-api.eu-central-1.amazonaws.com/dev/ocr -d "https://www.poemsearcher.com/images/poemsearcher/7d/7d40e9f03e14f9a92ef6a443110018e3.jpeg"
# gif
curl -X POST https://mcbn0jkd8l.execute-api.eu-central-1.amazonaws.com/dev/ocr -d "https://standing-with-israel.com/SWI/images/ACF12201.gif"
```

# languages needed
chi_sim,chi_tra,jpn,kor,spa,eng,fra,nld,deu,rus,lat,grc,ell,ara,hin,ben,

# pricing
1. GCP: First 1000 free, $43.5 for 30,000
2. AWS: 1000 free per month(3 months), $43.5 for 30,000

# improvements in build file
1. formats- giflib-devel 