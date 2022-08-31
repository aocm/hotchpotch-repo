<template>
  <div class="">
    <h1>This is a router sample page</h1>
    <p>{{data}}</p>
    <p>{{routeQuery}}</p>
    <p>{{apiResult}}</p>
    
  </div>
</template>
<script>
  // @ is an alias to /src
  
  export default {
    name: 'SampleRouterPage',
    components: {
    },
    data(){
      return {
        data : "test",
        apiResult:{},
        routeQuery: {},
      } 
    },
    async mounted(){
      console.log('mounted: ', this.$route.query)
      this.routeQuery = this.$route.query
      this.apiResult = await window.fetch('http://localhost:3000/posts/'+this.routeQuery.id).then(res=>res.json())
    },
    watch: {
      async $route(to) {
        console.log('watch: ', this.$route.query)
        this.routeQuery = to.query
        this.apiResult = await window.fetch('http://localhost:3000/posts/'+this.routeQuery.id).then(res=>res.json())
      },
    },
    
  }
  </script>