<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

</script>

<script>
import { ref } from 'vue';
import axios from "axios";

const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};

export default {
    data() {
        return {
            lavados: null,
            idlavado: null,
            idfermentacion: null,

        }
    },
    mounted() {
        this.viewDataTableLavado(); 
    },
    methods: {
        async CargarLotesLavado(){ 
            axios({
                method: 'POST',
                url: 'http://localhost:3000/CargarLotesLavado',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.lavados = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes de lavado cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                });
        },
        async viewDataTableLavado(){
            axios({
                method: 'GET',
                url: 'http://localhost:3000/ListarDatosLavado',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.lavados = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes disponibles para lavar', detail: '¡Todo bien!', life: 5000 });
                    console.log('Datos de las tablas: ', response.data);
                });
        },
        async registroActualizarLavado(row){
            try {
                const response = await axios.post(`http://localhost:3000/RegistroActualizarLavado`, {
                    idlavado: row.idlavado,
                    idfermentacion: row.idfermentacion,
                });
                this.$toast.add({ severity: 'success', summary: 'Lavado realizado exitosamente', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud POT:', error);
                this.$toast.add({ severity: 'warn', summary: 'Lavado fallido :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },

    }
};
</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Lavado</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Cargar Lotes a Lavar" icon="pi pi-plus" class="p-button-raised mr-2" @click="CargarLotesLavado()" />
                            <Button label="Ver lotes a Lavar" icon="pi pi-plus" class="p-button-success mr-2" @click="viewDataTableLavado()" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Codigo de lavado" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable v-bind="value" :value="lavados" class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes en lavado"
                    responsiveLayout="scroll">
                    <Column field="idlavado" header="Codigo de Lavado" :sortable="true" style="width:50px"></Column>
                    <Column field="idfermentacion" header="Codigo de Fermentacion" style="width:90px"></Column>
                    <Column field="kglavados" header="Kg a Lavar" style="width:120px"></Column>
                    <Column field="fecha" header="Fecha" style="width:120px"></Column>
                    <Column field="hora" header="Hora" style="width:120px"></Column>
                    <Column field="statusl" header="Status" style="width:150px"></Column>
                    <Column style="width:130px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1" @click="registroActualizarLavado(slotProps.data)" ></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '450px' }" header="Proceso de lavado" :modal="true"
                    class="p-fluid"></Dialog>
            </div>
        </div>
    </div>
</template>
