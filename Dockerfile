FROM node:7
MAINTAINER Waly debianw@gmail.com
EXPOSE 9000
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ADD . /usr/src/app
RUN npm install
CMD ["npm", "start"]

